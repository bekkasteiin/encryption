
// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, use_build_context_synchronously

import 'package:encrypt_decrypt_plus/encrypt_decrypt/aes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'PharmaSecure',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primarySwatch: Colors.indigo,
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: Color(0xFFF7F9FC),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: FirebaseAuth.instance.currentUser == null ? AuthPage() : MainNavigationPage(),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  _MainNavigationPageState createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [NewsPage(), HomePage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.indigo,
            unselectedItemColor: Colors.grey[500],
            selectedFontSize: 14,
            unselectedFontSize: 12,
            showUnselectedLabels: true,
            items: [
              _buildBarItem(Icons.home, "Главная", 0),
              _buildBarItem(Icons.medication, "Лекарство", 1),
              _buildBarItem(Icons.person, "Профиль", 2),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildBarItem(IconData icon, String label, int index) {
    bool isSelected = _currentIndex == index;
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: isSelected
            ? BoxDecoration(
          color: Colors.indigo.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        )
            : null,
        child: Icon(icon),
      ),
      label: label,
    );
  }
}

class AuthPage extends StatelessWidget {
  AuthPage({super.key});
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _authenticate(BuildContext context, bool isLogin) async {
    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      }
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => MainNavigationPage()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: TextStyle(fontFamily: 'Roboto'),
          ),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
  }

  InputDecoration _inputStyle(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    labelStyle: TextStyle(fontFamily: 'Roboto'),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    filled: true,
    fillColor: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB2FEFA), Color(0xFF0ED2F7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Hero(
                      tag: 'logo',
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.indigo.shade100,
                        child: Icon(Icons.medical_services, size: 48, color: Colors.indigo),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text("PharmaSecure",
                    style: TextStyle(fontSize: 24),),
                    const SizedBox(height: 16),
                    Text("Fully Homomorphic Encryption\npaillier cryptosystem",
                      style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,),
                    const SizedBox(height: 30),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputStyle("Email", Icons.email),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: _inputStyle("Пароль", Icons.lock),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () => _authenticate(context, true),
                      icon: const Icon(Icons.login, color: Colors.white),
                      label: const Text("Войти",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        elevation: 4,
                        backgroundColor: Colors.indigo,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _authenticate(context, false),
                      icon: const Icon(Icons.person_add, color: Colors.indigo),
                      label: const Text("Зарегистрироваться",
                          style: TextStyle(color: Colors.indigo, fontSize: 16)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.indigo),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final AES aes = AES(secretKey: "datadirr", iv: "datadirr");

  HomePage({super.key});

  Future<String?> encryptText(String text) async => await aes.encryptAES256CBC(text);
  Future<String?> decryptText(String text) async => await aes.decryptAES256CBC(text);

  Future<void> _addPatient(BuildContext context) async {
    final fioController = TextEditingController();
    final birthdateController = TextEditingController();
    final addressController = TextEditingController();
    final contactController = TextEditingController();
    final insuranceController = TextEditingController();
    final diagnosisController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Добавить пациента",
                      style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: fioController,
                    decoration: InputDecoration(labelText: "ФИО", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: birthdateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Дата рождения",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().subtract(Duration(days: 365 * 18)), // по умолчанию 18 лет
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        birthdateController.text = DateFormat('dd.MM.yyyy').format(pickedDate);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(labelText: "Адрес", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contactController,
                    decoration: InputDecoration(labelText: "Контактная информация", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: insuranceController,
                    decoration: InputDecoration(labelText: "Полис ОМС/ДМС", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: diagnosisController,
                    decoration: InputDecoration(labelText: "Диагноз", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(context), child: Text("Отмена")),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          await FirebaseFirestore.instance.collection('patients').add({
                            'fio': await encryptText(fioController.text),
                            'birthdate': await encryptText(birthdateController.text),
                            'address': await encryptText(addressController.text),
                            'contact': await encryptText(contactController.text),
                            'insurance': await encryptText(insuranceController.text),
                            'diagnosis': await encryptText(diagnosisController.text),
                          });
                          Navigator.pop(context);
                        },
                        child: Text("Сохранить", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPatientCard(Map<String, String?> patient) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.1), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Icon(Icons.person, color: Colors.indigo, size: 24,),
        ),
        title: Text("${patient['fio']}", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("Дата рождения: ", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(patient['birthdate'] ?? '', style: GoogleFonts.montserrat(fontSize: 14)),
                ],
              ),
              Row(
                children: [
                  Text("Адрес: ", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(patient['address'] ?? '', style: GoogleFonts.montserrat(fontSize: 14)),
                ],
              ),
              Row(
                children: [
                  Text("Контакты: ", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(patient['contact'] ?? '', style: GoogleFonts.montserrat(fontSize: 14)),
                ],
              ),
              Row(
                children: [
                  Text("Полис: ", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(patient['insurance'] ?? '', style: GoogleFonts.montserrat(fontSize: 14)),
                ],
              ),
              Row(
                children: [
                  Text("Диагноз: ", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(patient['diagnosis'] ?? '', style: GoogleFonts.montserrat(fontSize: 14)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Hero(tag: 'logo', child: Text("PatientSecure", style: GoogleFonts.montserrat())),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.indigo, Colors.deepPurple], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
        elevation: 0,
      ),
      backgroundColor: Color(0xFFF6F7FB),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('patients').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          return FutureBuilder(
            future: Future.wait(snapshot.data!.docs.map((doc) async {
              return {
                'fio': await decryptText(doc['fio']),
                'birthdate': await decryptText(doc['birthdate']),
                'address': await decryptText(doc['address']),
                'contact': await decryptText(doc['contact']),
                'insurance': await decryptText(doc['insurance']),
                'diagnosis': await decryptText(doc['diagnosis']),
              };
            }).toList()),
            builder: (context, AsyncSnapshot<List<Map<String, String?>>> asyncSnapshot) {
              if (!asyncSnapshot.hasData) return Center(child: CircularProgressIndicator());
              final patients = asyncSnapshot.data!;
              return ListView.builder(
                itemCount: patients.length,
                itemBuilder: (context, index) => _buildPatientCard(patients[index]),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addPatient(context),
        backgroundColor: Colors.indigo,
        label: Text("Добавить", style: TextStyle(color: Colors.white)),
        icon: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class NewsItem {
  final String title;
  final String content;
  final String imagePath;

  NewsItem({required this.title, required this.content, required this.imagePath});
}

class NewsPage extends StatelessWidget {
  NewsPage({super.key});

  final List<NewsItem> newsList = [
    NewsItem(
      title: 'В Казахстане впервые установили эндопротезы подросткам - раньше ждали до 18 лет',
      content: 'В Казахстане впервые проведены уникальные операции по установке эндопротезов подросткам. До этого подобные вмешательства выполнялись только взрослым, а детям с тяжелыми ортопедическими патологиями приходилось ждать совершеннолетия. Но в таких случаях время зачастую играло против пациента и болезнь прогрессировала. Историческим прецедентом стало внедрение взрослых технологий в детскую практику, которые помог реализовать ментор Алексей Белокобылов, заведующий отделением, руководитель Республиканского центра эндопротезирования суставов, врач травматолог-ортопед высшей квалификационной категории, кандидат медицинских наук. Операции выполнены в Астане благодаря сотрудничеству детских и взрослых ортопедов, при поддержке корпоративного фонда "BI-Жұлдызай" и Детской городской больницы.В 2025 году участие в отборочных этапах приняли свыше 6 тысяч детей. Финальные мероприятия фестиваля пройдут в Астане с 25 мая по 2 июня. Гала-концерт состоится 1 июня во Дворце единоборств "Жекпе-жек". "BI-Жұлдызай" остается единственным корпоративным фондом в Казахстане, системно поддерживающим все направления развития особенных детей.',
      imagePath: 'assets/news/1.jpeg',
    ),
    NewsItem(
      title: 'Опасные процедуры: Минздрав обратился к казахстанцам',
      content: 'В Казахстане усиливают контроль за процедурными кабинетами после серии нарушений, включая работу без лицензий, отсутствие квалифицированного персонала и несоблюдение условий хранения лекарств. Минздрав призвал граждан проверять клиники перед получением медуслуг. С начала 2024 года по первый квартал 2025-го в Казахстане зафиксированы многочисленные нарушения при оказании процедурных медицинских услуг. По данным Министерства здравоохранения, в Комитет медицинского и фармацевтического контроля поступило семь обращений от граждан. По каждому обращению были проведены внеплановые проверки.',
      imagePath: 'assets/news/2.webp',
    ),
    NewsItem(
      title: 'Реформирование ОСМС: Вводится единая платежная система',
      content: 'В Казахстане начато внедрение Единой системы оплаты медицинской помощи (ЕСОМП). Как сообщили в Министерстве здравоохранения, это делается в рамках поручения Главы государства о повышении эффективности системы обязательного социального медицинского страхования (ОСМС). Новый цифровой инструмент обеспечит контроль качества и финансирования предоставляемых медицинских услуг в рамках ГОБМП и ОСМС.',
      imagePath: 'assets/news/3.webp',
    ),
    NewsItem(
      title: 'Прогноз магнитных бурь на апрель',
      content: 'В апреле этого года прогнозируется 6 дней магнитных бурь начального уровня. По прогнозу Лаборатории солнечной астрономии ИКИ и ИСЗФ, геомагнитные возмущения с уровнем G1 ожидаются 5, 8, 9, 10, 22 и 24 апреля. Кроме того, 8 дней апреля будет наблюдаться повышенная геомагнитная активность. В эти дни, 6, 7, 11, 12, 13, 14, 21 и 25 апреля, вероятность возникновения возмущений в земной магнитосфере будет выше, что может повлиять на атмосферные условия и вызывать легкое беспокойство у метеочувствительных людей.',
      imagePath: 'assets/news/4.webp',
    ),
    NewsItem(
      title: 'Как избежать осложнений после удаления зубов мудрости. Рекомендации врача',
      content: 'Наверняка каждый хоть раз сталкивался с проблемами из–за зубов мудрости. Глубокие кариозные поражения, воспаление десны, ноющая боль, удаление перед установкой брекетов — все это заставляет нас обращаться к стоматологу. Однако немногие знают, что до 30 процентов случаев удаления зубов мудрости может приводить к опасным осложнениям.',
      imagePath: 'assets/news/5.webp',
    ),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Новости'), centerTitle: false),
      body: ListView.builder(
        itemCount: newsList.length,
        itemBuilder: (context, index) {
          final news = newsList[index];

          if (index == 0) {
            // Большая карточка с наложением текста
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>NewsDetailPage(news: news,)));
                },
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        news.imagePath,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black54, Colors.transparent],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Text(
                        news.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Компактный стиль карточек: картинка слева, текст справа
          return GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (_)=>NewsDetailPage(news: news,)));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      news.imagePath,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          news.title,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6),
                        Text(
                          news.content,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class NewsDetailPage extends StatelessWidget {
  final NewsItem news;

  const NewsDetailPage({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(news.title),
      ),
      body: ListView(
        children: [
          Image.asset(
            news.imagePath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 250,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              news.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              news.content,
              style: const TextStyle(fontSize: 16, height: 1.5, fontFamily: "Roboto"),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.deepPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text("Профиль"),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => AuthPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo, Colors.deepPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 55, color: Colors.indigo),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.email ?? "Неизвестный пользователь",
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 3,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.email, color: Colors.indigo),
                  title: const Text("Почта"),
                  subtitle: Text(user?.email ?? "Не указана"),
                ),
                const Divider(indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.timer_outlined, color: Colors.indigo),
                  title: const Text("Время регистрации"),
                  subtitle: Text(DateFormat('dd MMMM yyyy, HH:mm').format(user?.metadata.creationTime ?? DateTime.now())),
                ),
                const Divider(indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.badge_outlined, color: Colors.indigo),
                  title: const Text("Должность"),
                  subtitle: Text("Специалист"),
                ),
                const Divider(indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.key, color: Colors.indigo),
                  title: const Text("UID"),
                  subtitle: Text(user?.uid ?? "-"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
