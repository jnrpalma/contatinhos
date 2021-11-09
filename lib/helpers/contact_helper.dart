import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String contactTable = "contactTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";

class ContactHelper {
  //criando instancia interna do objeto
  static final ContactHelper _instance = ContactHelper.internal();
  factory ContactHelper() => _instance;
  ContactHelper.internal();

//criando o banco de dados
  Database? _db;
  Future<Database?> get db async {
    // ignore: unnecessary_null_comparison
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

//funcao para inializar o banco e pegar local do mesmo
  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'contactsnew.db');
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
          'CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT, $phoneColumn TEXT, $imgColumn TEXT)');
    });
  }

//salvar contato
  Future<Contact> saveContact(Contact contact) async {
    Database? dbContact = await db;
    contact.id = await dbContact!.insert(contactTable, contact.toMap());
    return contact;
  }

//pegar contatos e jogar no map
  Future<Contact?> getContact(int id) async {
    Database? dbContact = await db;
    List<Map> maps = await dbContact!.query(contactTable,
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
        where: '$idColumn = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  //deletar contato
  Future<int> deleteContact(int id) async {
    Database? dbContact = await db;
    return await dbContact!
        .delete(contactTable, where: '$idColumn = ?', whereArgs: [id]);
  }

//alterar o contato
  Future<int> updateContact(Contact contact) async {
    Database? dbContact = await db;
    return await dbContact!.update(contactTable, contact.toMap(),
        where: '$idColumn = ?', whereArgs: [contact.id]);
  }

//pegar todos da lista
  Future<List> getAllContacts() async {
    Database? dbContact = await db;
    List listMap = await dbContact!.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = [];
    for (Map m in listMap) {
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

//obter a contagem de todos os contatos da lista
  Future<int?> getNumber() async {
    Database? dbContact = await db;
    return Sqflite.firstIntValue(
      await dbContact!.rawQuery('SELECT COUNT(*) FROM $contactTable'),
    );
  }

//fechar o banco
  Future close() async {
    Database? dbContact = await db;
    dbContact!.close();
  }
}

// molde do contato
class Contact {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? img;

  Contact();

  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img
    };
    // ignore: unnecessary_null_comparison
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return 'Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)';
  }
}
