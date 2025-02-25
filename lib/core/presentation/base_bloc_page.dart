// // lib/core/presentation/base_bloc_page.dart

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// abstract class BaseBlocPage<T extends Bloc> extends StatefulWidget {
//   const BaseBlocPage({super.key});
// }

// abstract class BaseBlocState<P extends BaseBlocPage, B extends Bloc>
//     extends State<P> {
//   late final B bloc;

//   @override
//   void initState() {
//     super.initState();
//     bloc = createBloc();
//     onBlocCreated(bloc);
//   }

//   B createBloc();
//   void onBlocCreated(B bloc) {}

//   @override
//   void dispose() {
//     bloc.close();
//     super.dispose();
//   }
// }
