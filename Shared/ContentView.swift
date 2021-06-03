//
//  ContentView.swift
//  Shared
//
//  Created by ijichi on 2021/05/17.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.created_at, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    
    
    var body: some View {
        NavigationView {    // ナビゲーションバーを表示する為に必要
        List {
            ForEach(items, id: \.self) { item in
                NavigationLink(destination:
                                EditView(item: item ).navigationTitle("編集")) {
                    Text(item.key_name ?? "鍵未登録")
                    Text(item.user_name ?? "未使用")
                    Text("\(item.created_at!, formatter: itemFormatter)")
                }
            }
            .onDelete(perform: deleteItems)
        }
        .navigationTitle("鍵管理一覧")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            #if os(iOS)
            /// ナビゲーションバーの左にEditボタンを配置
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
            #endif

            /// ナビゲーションバーの右に+ボタン配置
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: addItem) {
                    Label("Add Item", systemImage: "plus")
                }
            
            //ToolbarItem(placement: .navigationBarTrailing){
            //    NavigationLink(destination: NewView().navigationTitle("新規登録")) {
            //        Image(systemName: "plus")
            //    }
            //}
        }
        }
        Spacer()
    }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.key_name = "新規鍵"
            newItem.user_name = "使用者名"
            
            newItem.created_at = Date()
            

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

struct NewView: View {
    var body: some View {
        Spacer()
        //Image(systemName: "photo")
        NavigationLink(destination: CameraView().navigationTitle("カメラ機能")
        ) {
            Image(systemName: "photo")
        }
        Spacer()
        HStack {
            Text("鍵名称：")
            TextField("鍵名称", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
        }
        Spacer()
        HStack {
            Text("使用者名：")
            TextField("使用者名", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
            NavigationLink(destination: NameView().navigationTitle("使用者名一覧").toolbar {
                
                /// ナビゲーションバー右
                ToolbarItem(placement: .navigationBarTrailing){
                    Button(action: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/{}/*@END_MENU_TOKEN@*/) {
                        Image(systemName: "plus")
                    }
                
                }
            }) {
                Image(systemName: "plus")
            }
            Spacer()
        }
        Spacer()
        HStack {
            Text("備考：")
            TextField("備考", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
        }
        Spacer()
        
    }
}

struct EditView: View {
    let item: Item
    @Environment(\.managedObjectContext) private var viewContext

    @State  var kname: String = ""
    @State  var uname: String = ""
    @State  var note: String = ""
    
    @State var imageData : Data = .init(capacity:0)
    @State var source:UIImagePickerController.SourceType = .photoLibrary
    
    @State var isActionSheet = false
    @State var isImagePicker = false
    
    
    var body: some View {

        Spacer()
        //Image(systemName: "photo")
       
        VStack(spacing:0){
                ZStack{
                    NavigationLink(
                        destination: Imagepicker(show: $isImagePicker, image: $imageData, sourceType: source),
                        isActive:$isImagePicker,
                        label: {
                            Text("")
                        })
                    VStack{
                        if imageData.count != 0{
                            Image(uiImage: UIImage(data: self.imageData)!)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 250)
                                .cornerRadius(15)
                                .padding()
                        }
                        HStack(spacing:30){
                            Button(action: {
                                    self.source = .photoLibrary
                                    self.isImagePicker.toggle()
                            }, label: {
                                Text("アルバム")
                            })
                            Button(action: {
                                    self.source = .camera
                                    self.isImagePicker.toggle()
                            }, label: {
                                Text("写真")
                            })
                        }
                    }
                }
        }
        
        Spacer()
        HStack {
            Text("鍵名称：")
            TextField("鍵名称", text: $kname).onAppear {
                self.kname = "\(item.key_name!)"
            }
        }
        Spacer()
        HStack {
            Text("使用者名：")
            TextField("使用者名", text: $uname).onAppear {
                if item.user_name != nil{
                    self.uname = "\(item.user_name!)"
                }
            }
            NavigationLink(destination: NameView()) {
                Image(systemName: "plus")
            }
            
            Spacer()
        }
        Spacer()
        HStack {
            Text("備考：")
            TextField("備考", text: $note)
        }.onAppear {
            if item.note != nil{
                self.note = "\(item.note!)"
            }
            
        }
        
        Spacer()
        
        Button(action: updateItem) {
            Text("保存")
        }
        
    }
    private func updateItem() {
        withAnimation {
            //let newUser = User(context: viewContext)
            //newUser.name = "使用者"
            item.key_name = kname
            item.user_name = uname
            item.note = note
            //item.image_data = imageData
            
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
}

struct NameView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \User.name, ascending: true)],
        animation: .default)
    private var users: FetchedResults<User>
    
    
    
    @State  var username: String = ""
    
    var body: some View {
        List {
            ForEach(users, id: \.self) { user in
                NavigationLink(destination:
                                EditUserView(user: user ).navigationTitle("名前編集")) {
                    Text(user.name ?? "使用者名")
                    Text("\(user.created_at!, formatter: itemFormatter)")
         //Text("使用者名:")
         /*TextField("使用者名", text: $username).onAppear {
             self.username = "\(user.name!)"
         }*/
         }
            
        }.onDelete(perform: deleteUsers)
        
        /*List(1..<10) { index in
            Text("使用者名\(index):")
            TextField("使用者名\(index)", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
        }*/
    }.navigationTitle("使用者名一覧")
        //.navigationBarTitleDisplayMode(.inline)
        .toolbar {
            #if os(iOS)
            /// ナビゲーションバーの左にEditボタンを配置
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
            #endif
        /// ナビゲーションバー右
        ToolbarItem(placement: .navigationBarTrailing){
            Button(action: addUser) {
                Image(systemName: "plus")
            }
        }
    }
    
        
    }
    
    
    private func addUser() {
        withAnimation {
            let newUser = User(context: viewContext)
            newUser.name = "使用者"
            newUser.created_at = Date()
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    
    
    private func deleteUsers(offsets: IndexSet) {
        withAnimation {
            offsets.map { users[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    
    
}

struct EditUserView: View {
    let user: User
    @Environment(\.managedObjectContext) private var viewContext

    @State  var uname: String = ""
    
    var body: some View {

        Spacer()
        HStack {
            Text("使用者名：")
            TextField("使用者名", text: $uname).onAppear {
                if user.name != nil{
                    self.uname = "\(user.name!)"
                }
            }
            Spacer()
        }
        
        Spacer()
        
        Button(action: updateUser) {
            Text("保存")
        }
        Spacer()
        
    }
    private func updateUser() {
        withAnimation {
            user.name = uname
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
 
}

//カメラ
struct Imagepicker : UIViewControllerRepresentable {
    
    @Binding var show:Bool
    @Binding var image:Data
    var sourceType:UIImagePickerController.SourceType
 
    func makeCoordinator() -> Imagepicker.Coodinator {
        
        return Imagepicker.Coordinator(parent: self)
    }
      
    func makeUIViewController(context: UIViewControllerRepresentableContext<Imagepicker>) -> UIImagePickerController {
        
        let controller = UIImagePickerController()
        controller.sourceType = sourceType
        controller.delegate = context.coordinator
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<Imagepicker>) {
    }
    
    class Coodinator: NSObject,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
        
        var parent : Imagepicker
        
        init(parent : Imagepicker){
            self.parent = parent
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.parent.show.toggle()
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            let image = info[.originalImage] as! UIImage
            let data = image.pngData()
            self.parent.image = data!
            self.parent.show.toggle()
        }
    }
}

struct CameraView: View {
    
    @State var imageData : Data = .init(capacity:0)
    @State var source:UIImagePickerController.SourceType = .photoLibrary
    
    @State var isActionSheet = false
    @State var isImagePicker = false
    
    var body: some View {
                VStack(spacing:0){
                        ZStack{
                            NavigationLink(
                                destination: Imagepicker(show: $isImagePicker, image: $imageData, sourceType: source),
                                isActive:$isImagePicker,
                                label: {
                                    Text("")
                                })
                            VStack{
                                if imageData.count != 0{
                                    Image(uiImage: UIImage(data: self.imageData)!)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 250)
                                        .cornerRadius(15)
                                        .padding()
                                }
                                HStack(spacing:30){
                                    Button(action: {
                                            self.source = .photoLibrary
                                            self.isImagePicker.toggle()
                                    }, label: {
                                        Text("アルバム")
                                    })
                                    Button(action: {
                                            self.source = .camera
                                            self.isImagePicker.toggle()
                                    }, label: {
                                        Text("写真")
                                    })
                                }
                            }
                        }
                }
    }
}
