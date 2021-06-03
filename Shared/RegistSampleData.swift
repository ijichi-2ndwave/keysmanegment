//
//  RegistSampleData.swift
//  keysManegment
//
//  Created by ijichi on 2021/05/18.
//

import CoreData
 
func registSampleData(context: NSManagedObjectContext) {
    
    /// Itemテーブル初期値
    let itemList = [
        ["001", "登録鍵①", "001", "備考①", "バスケット","2021/05/10","2021/05/10"],
        ["002", "登録鍵②", "002", "備考②", "サッカー","2021/05/10","2021/05/10"],
        ["003", "登録鍵③", "003", "備考③", "","2021/05/10","2021/05/10"],
        ["004", "登録鍵④", "004", "備考④", "吹奏楽","2021/05/10","2021/05/10"],
        ["005", "登録鍵⑤", "005", "備考⑤", "サッカー","2021/05/10","2021/05/10"]
    ]
        
    /// Clubテーブル初期値
    let userList = [
        ["001", "ユーザー１さん","2021/05/10","2021/05/10"],
        ["002", "ユーザー２さん","2021/05/10","2021/05/10"],
        ["003", "ユーザー３さん","2021/05/10","2021/05/10"],
        ["004", "ユーザー４さん","2021/05/10","2021/05/10"]
    ]
    
    /// Itemテーブル全消去
    let fetchRequestItem = NSFetchRequest<NSFetchRequestResult>()
    fetchRequestItem.entity = Item.entity()
    let items = try? context.fetch(fetchRequestItem) as? [Item]
    for item in items! {
        context.delete(item)
    }
    
    /// Clubテーブル全消去
    let fetchRequestUser = NSFetchRequest<NSFetchRequestResult>()
    fetchRequestUser.entity = User.entity()
    let users = try? context.fetch(fetchRequestUser) as? [User]
    for user in users! {
        context.delete(user)
    }
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy/M/d"
    
    /// Clubテーブル登録
    for user in userList {
        let newUser = User(context: context)
        newUser.uid = Int16(user[0])!  // user_id
        newUser.name = user[1]   // 使用者名
        newUser.created_at = dateFormatter.date(from: user[2])!  //
        newUser.updated_at = dateFormatter.date(from: user[3])!  //
    }
 
    
    /// Studentテーブル登録
    for item in itemList {
        let newItem = Item(context: context)
        newItem.id = Int16(item[0])! // id
        newItem.key_name = item[1]       // 鍵名称
        newItem.user_id = Int16(item[2])! // userId
        newItem.note = item[3]  // 備考
        newItem.created_at = dateFormatter.date(from: item[5])!  //
        newItem.updated_at = dateFormatter.date(from: item[6])! //
 
        /// リレーションの設定
        fetchRequestUser.predicate = NSPredicate(format: "uid = %@", item[2])
        let result = try? context.fetch(fetchRequestUser) as? [User]
        if result!.count > 0 {
            /// Student -> Clubへのリレーション
            newItem.username = result![0]
        }
    }
    
    /// コミット
    try? context.save()
}
