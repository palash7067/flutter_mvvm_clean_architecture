import 'package:charterer/presentation/screens/add_charterer.dart';
import 'package:charterer/presentation/widgets/custom_loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:sizer/sizer.dart';
import 'core/theme/theme.dart';
import 'core/utils/environment.dart';
import 'di/injection.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: Environment.fileName);
  DependencyInjector.inject();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Charterer',
        theme: ApplicationTheme.getAppThemeData(),
        home: const AddCharterer(),
        builder: FlutterSmartDialog.init(
          loadingBuilder: (String msg) => const CustomLoadingWidget(),
        ),
      );
    });
  }
}