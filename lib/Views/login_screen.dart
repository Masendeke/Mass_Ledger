// import 'package:flutter/material.dart';

// import 'app_shell.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() =>
//       _LoginScreenState();
// }

// class _LoginScreenState
//     extends State<LoginScreen> {
//   // ============================================================
//   // CONTROLLERS
//   // ============================================================

//   final _formKey =
//       GlobalKey<FormState>();

//   final emailController =
//       TextEditingController();

//   final passwordController =
//       TextEditingController();

//   // ============================================================
//   // VARIABLES
//   // ============================================================

//   bool obscurePassword = true;
//   bool isLoading = false;

//   @override
//   void dispose() {
//     emailController.dispose();
//     passwordController.dispose();

//     super.dispose();
//   }

//   // ============================================================
//   // LOGIN
//   // ============================================================

//   Future<void> _login() async {
//     if (!_formKey.currentState!
//         .validate()) {
//       return;
//     }

//     setState(() {
//       isLoading = true;
//     });

//     // ----------------------------------------------------------
//     // TEMPORARY LOGIN
//     // ----------------------------------------------------------
//     //
//     // This allows you to test the application.
//     //
//     // Later, replace this section with Supabase authentication.
//     // ----------------------------------------------------------

//     await Future.delayed(
//       const Duration(seconds: 1),
//     );

//     if (!mounted) return;

//     setState(() {
//       isLoading = false;
//     });

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (_) =>
//             const AppShell(),
//       ),
//     );
//   }

//   // ============================================================
//   // FORGOT PASSWORD
//   // ============================================================

//   void _forgotPassword() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         final resetController =
//             TextEditingController();

//         return AlertDialog(
//           title: const Text(
//             'Reset Password',
//           ),

//           content: Column(
//             mainAxisSize:
//                 MainAxisSize.min,
//             children: [
//               const Text(
//                 'Enter your email address and we will send you a password reset link.',
//               ),

//               const SizedBox(height: 15),

//               TextField(
//                 controller:
//                     resetController,
//                 keyboardType:
//                     TextInputType.emailAddress,
//                 decoration:
//                     const InputDecoration(
//                   labelText: 'Email',
//                   prefixIcon:
//                       Icon(Icons.email_outlined),
//                 ),
//               ),
//             ],
//           ),

//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: const Text(
//                 'Cancel',
//               ),
//             ),

//             ElevatedButton(
//               onPressed: () {
//                 if (resetController
//                     .text
//                     .trim()
//                     .isEmpty) {
//                   return;
//                 }

//                 Navigator.pop(context);

//                 ScaffoldMessenger.of(
//                   context,
//                 ).showSnackBar(
//                   const SnackBar(
//                     content: Text(
//                       'Password reset link sent.',
//                     ),
//                   ),
//                 );
//               },
//               child: const Text(
//                 'Send',
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ============================================================
//   // SIGN UP
//   // ============================================================

//   void _signUp() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         final nameController =
//             TextEditingController();

//         final emailController =
//             TextEditingController();

//         final passwordController =
//             TextEditingController();

//         return AlertDialog(
//           title: const Text(
//             'Create Account',
//           ),

//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize:
//                   MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller:
//                       nameController,
//                   decoration:
//                       const InputDecoration(
//                     labelText: 'Full Name',
//                     prefixIcon:
//                         Icon(Icons.person_outline),
//                   ),
//                 ),

//                 const SizedBox(height: 10),

//                 TextField(
//                   controller:
//                       emailController,
//                   keyboardType:
//                       TextInputType.emailAddress,
//                   decoration:
//                       const InputDecoration(
//                     labelText: 'Email',
//                     prefixIcon:
//                         Icon(Icons.email_outlined),
//                   ),
//                 ),

//                 const SizedBox(height: 10),

//                 TextField(
//                   controller:
//                       passwordController,
//                   obscureText: true,
//                   decoration:
//                       const InputDecoration(
//                     labelText: 'Password',
//                     prefixIcon:
//                         Icon(Icons.lock_outline),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: const Text(
//                 'Cancel',
//               ),
//             ),

//             ElevatedButton(
//               onPressed: () {
//                 if (emailController
//                         .text
//                         .trim()
//                         .isEmpty ||
//                     passwordController
//                         .text
//                         .trim()
//                         .isEmpty) {
//                   return;
//                 }

//                 Navigator.pop(context);

//                 ScaffoldMessenger.of(
//                   context,
//                 ).showSnackBar(
//                   const SnackBar(
//                     content: Text(
//                       'Account created successfully.',
//                     ),
//                   ),
//                 );
//               },
//               child: const Text(
//                 'Create Account',
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ============================================================
//   // GOOGLE LOGIN
//   // ============================================================

//   void _googleLogin() {
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(
//       const SnackBar(
//         content: Text(
//           'Google login will be connected to authentication.',
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // APPLE LOGIN
//   // ============================================================

//   void _appleLogin() {
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(
//       const SnackBar(
//         content: Text(
//           'Apple login will be connected to authentication.',
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor:
//           const Color(0xFFF7F8FA),

//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               // ==================================================
//               // NAVY HEADER
//               // ==================================================

//               Container(
//                 width: double.infinity,
//                 padding:
//                     const EdgeInsets.fromLTRB(
//                   25,
//                   30,
//                   25,
//                   45,
//                 ),

//                 decoration:
//                     const BoxDecoration(
//                   color:
//                       Color(0xFF09275F),

//                   borderRadius:
//                       BorderRadius.vertical(
//                     bottom:
//                         Radius.circular(28),
//                   ),
//                 ),

//                 child: Column(
//                   children: [
//                     // --------------------------------------------
//                     // LOGO
//                     // --------------------------------------------

//                     Container(
//                       width: 75,
//                       height: 75,

//                       decoration:
//                           BoxDecoration(
//                         color: Colors.white
//                             // ignore: deprecated_member_use
//                             .withOpacity(.12),

//                         borderRadius:
//                             BorderRadius.circular(
//                           18,
//                         ),

//                         border: Border.all(
//                           color: Colors.white
//                               // ignore: deprecated_member_use
//                               .withOpacity(.2),
//                         ),
//                       ),

//                       child: const Center(
//                         child:
//                             _MassLedgerLogo(),
//                       ),
//                     ),

//                     const SizedBox(
//                         height: 15),

//                     // --------------------------------------------
//                     // TITLE
//                     // --------------------------------------------

//                     const Text(
//                       'Mass Ledger',
//                       style: TextStyle(
//                         color:
//                             Colors.white,
//                         fontSize: 25,
//                         fontWeight:
//                             FontWeight.bold,
//                       ),
//                     ),

//                     const SizedBox(
//                         height: 5),

//                     const Text(
//                       'Track. Analyze. Grow.',
//                       style: TextStyle(
//                         color:
//                             Colors.white70,
//                         fontSize: 13,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // ==================================================
//               // LOGIN CARD
//               // ==================================================

//               Transform.translate(
//                 offset:
//                     const Offset(0, -25),

//                 child: Container(
//                   margin:
//                       const EdgeInsets.symmetric(
//                     horizontal: 18,
//                   ),

//                   padding:
//                       const EdgeInsets.all(20),

//                   decoration:
//                       BoxDecoration(
//                     color: Colors.white,

//                     borderRadius:
//                         BorderRadius.circular(
//                       18,
//                     ),

//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black
//                             // ignore: deprecated_member_use
//                             .withOpacity(.08),
//                         blurRadius: 20,
//                         offset:
//                             const Offset(
//                           0,
//                           8,
//                         ),
//                       ),
//                     ],
//                   ),

//                   child: Form(
//                     key: _formKey,

//                     child: Column(
//                       crossAxisAlignment:
//                           CrossAxisAlignment.start,

//                       children: [
//                         // ========================================
//                         // WELCOME
//                         // ========================================

//                         const Text(
//                           'Welcome back!',
//                           style: TextStyle(
//                             fontSize: 21,
//                             fontWeight:
//                                 FontWeight.bold,
//                             color:
//                                 Color(0xFF09275F),
//                           ),
//                         ),

//                         const SizedBox(
//                             height: 4),

//                         const Text(
//                           'Login to continue',
//                           style: TextStyle(
//                             color:
//                                 Colors.black54,
//                             fontSize: 12,
//                           ),
//                         ),

//                         const SizedBox(
//                             height: 22),

//                         // ========================================
//                         // EMAIL
//                         // ========================================

//                         const Text(
//                           'Email',
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight:
//                                 FontWeight.w600,
//                           ),
//                         ),

//                         const SizedBox(
//                             height: 7),

//                         TextFormField(
//                           controller:
//                               emailController,

//                           keyboardType:
//                               TextInputType
//                                   .emailAddress,

//                           decoration:
//                               const InputDecoration(
//                             hintText:
//                                 'you@example.com',
//                             prefixIcon:
//                                 Icon(
//                               Icons
//                                   .email_outlined,
//                             ),
//                           ),

//                           validator:
//                               (value) {
//                             if (value ==
//                                     null ||
//                                 value
//                                     .trim()
//                                     .isEmpty) {
//                               return 'Please enter your email';
//                             }

//                             if (!value
//                                 .contains('@')) {
//                               return 'Enter a valid email';
//                             }

//                             return null;
//                           },
//                         ),

//                         const SizedBox(
//                             height: 15),

//                         // ========================================
//                         // PASSWORD
//                         // ========================================

//                         const Text(
//                           'Password',
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight:
//                                 FontWeight.w600,
//                           ),
//                         ),

//                         const SizedBox(
//                             height: 7),

//                         TextFormField(
//                           controller:
//                               passwordController,

//                           obscureText:
//                               obscurePassword,

//                           decoration:
//                               InputDecoration(
//                             hintText:
//                                 '••••••••',

//                             prefixIcon:
//                                 const Icon(
//                               Icons
//                                   .lock_outline,
//                             ),

//                             suffixIcon:
//                                 IconButton(
//                               onPressed: () {
//                                 setState(() {
//                                   obscurePassword =
//                                       !obscurePassword;
//                                 });
//                               },
//                               icon: Icon(
//                                 obscurePassword
//                                     ? Icons
//                                         .visibility_outlined
//                                     : Icons
//                                         .visibility_off_outlined,
//                               ),
//                             ),
//                           ),

//                           validator:
//                               (value) {
//                             if (value ==
//                                     null ||
//                                 value
//                                     .isEmpty) {
//                               return 'Please enter your password';
//                             }

//                             if (value.length <
//                                 6) {
//                               return 'Password must be at least 6 characters';
//                             }

//                             return null;
//                           },
//                         ),

//                         const SizedBox(
//                             height: 8),

//                         // ========================================
//                         // FORGOT PASSWORD
//                         // ========================================

//                         Align(
//                           alignment:
//                               Alignment
//                                   .centerRight,

//                           child:
//                               TextButton(
//                             onPressed:
//                                 _forgotPassword,

//                             child:
//                                 const Text(
//                               'Forgot Password?',
//                               style:
//                                   TextStyle(
//                                 fontSize:
//                                     11,
//                                 color:
//                                     Color(
//                                   0xFF09275F,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),

//                         const SizedBox(
//                             height: 4),

//                         // ========================================
//                         // LOGIN BUTTON
//                         // ========================================

//                         SizedBox(
//                           width:
//                               double.infinity,
//                           height: 50,

//                           child:
//                               ElevatedButton(
//                             onPressed:
//                                 isLoading
//                                     ? null
//                                     : _login,

//                             style:
//                                 ElevatedButton
//                                     .styleFrom(
//                               backgroundColor:
//                                   const Color(
//                                 0xFF09275F,
//                               ),

//                               foregroundColor:
//                                   Colors.white,

//                               shape:
//                                   RoundedRectangleBorder(
//                                 borderRadius:
//                                     BorderRadius
//                                         .circular(
//                                   9,
//                                 ),
//                               ),
//                             ),

//                             child: isLoading
//                                 ? const SizedBox(
//                                     width: 22,
//                                     height: 22,
//                                     child:
//                                         CircularProgressIndicator(
//                                       strokeWidth:
//                                           2,
//                                       color:
//                                           Colors.white,
//                                     ),
//                                   )
//                                 : const Text(
//                                     'Login',
//                                     style:
//                                         TextStyle(
//                                       fontWeight:
//                                           FontWeight.bold,
//                                     ),
//                                   ),
//                           ),
//                         ),

//                         const SizedBox(
//                             height: 18),

//                         // ========================================
//                         // DIVIDER
//                         // ========================================

//                         Row(
//                           children: [
//                             Expanded(
//                               child:
//                                   Divider(
//                                 color:
//                                     Colors.grey
//                                         .shade300,
//                               ),
//                             ),

//                             const Padding(
//                               padding:
//                                   EdgeInsets
//                                       .symmetric(
//                                 horizontal:
//                                     10,
//                               ),
//                               child: Text(
//                                 'or continue with',
//                                 style:
//                                     TextStyle(
//                                   color:
//                                       Colors.black45,
//                                   fontSize:
//                                       11,
//                                 ),
//                               ),
//                             ),

//                             Expanded(
//                               child:
//                                   Divider(
//                                 color:
//                                     Colors.grey
//                                         .shade300,
//                               ),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(
//                             height: 16),

//                         // ========================================
//                         // GOOGLE + APPLE
//                         // ========================================

//                         Row(
//                           children: [
//                             Expanded(
//                               child:
//                                   OutlinedButton
//                                       .icon(
//                                 onPressed:
//                                     _googleLogin,

//                                 icon:
//                                     const Text(
//                                   'G',
//                                   style:
//                                       TextStyle(
//                                     fontSize:
//                                         17,
//                                     fontWeight:
//                                         FontWeight.bold,
//                                   ),
//                                 ),

//                                 label:
//                                     const Text(
//                                   'Google',
//                                 ),

//                                 style:
//                                     OutlinedButton
//                                         .styleFrom(
//                                   foregroundColor:
//                                       Colors.black87,
//                                   side:
//                                       BorderSide(
//                                     color: Colors
//                                         .grey
//                                         .shade300,
//                                   ),
//                                 ),
//                               ),
//                             ),

//                             const SizedBox(
//                                 width: 10),

//                             Expanded(
//                               child:
//                                   OutlinedButton
//                                       .icon(
//                                 onPressed:
//                                     _appleLogin,

//                                 icon:
//                                     const Icon(
//                                   Icons.apple,
//                                   size: 19,
//                                 ),

//                                 label:
//                                     const Text(
//                                   'Apple',
//                                 ),

//                                 style:
//                                     OutlinedButton
//                                         .styleFrom(
//                                   foregroundColor:
//                                       Colors.black87,
//                                   side:
//                                       BorderSide(
//                                     color: Colors
//                                         .grey
//                                         .shade300,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(
//                             height: 18),

//                         // ========================================
//                         // SIGN UP
//                         // ========================================

//                         Center(
//                           child: Row(
//                             mainAxisAlignment:
//                                 MainAxisAlignment
//                                     .center,

//                             children: [
//                               const Text(
//                                 "Don't have an account? ",
//                                 style:
//                                     TextStyle(
//                                   fontSize:
//                                       11,
//                                   color:
//                                       Colors.black54,
//                                 ),
//                               ),

//                               GestureDetector(
//                                 onTap:
//                                     _signUp,

//                                 child:
//                                     const Text(
//                                   'Sign up',
//                                   style:
//                                       TextStyle(
//                                     fontSize:
//                                         11,
//                                     color:
//                                         Color(
//                                       0xFF09275F,
//                                     ),
//                                     fontWeight:
//                                         FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//               // ==================================================
//               // DESCRIPTION
//               // ==================================================

//               const Padding(
//                 padding:
//                     EdgeInsets.fromLTRB(
//                   30,
//                   0,
//                   30,
//                   25,
//                 ),

//                 child: Text(
//                   'A simple daily profit & loss tracker that helps you stay consistent and in control of your finances.',
//                   textAlign:
//                       TextAlign.center,

//                   style: TextStyle(
//                     color:
//                         Colors.black45,
//                     fontSize: 11,
//                     height: 1.5,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ================================================================
// // MASS LEDGER LOGO
// // ================================================================

// class _MassLedgerLogo
//     extends StatelessWidget {
//   const _MassLedgerLogo();

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 42,
//       height: 42,
//       child: CustomPaint(
//         painter:
//             _LogoPainter(),
//       ),
//     );
//   }
// }

// class _LogoPainter
//     extends CustomPainter {
//   @override
//   void paint(
//     Canvas canvas,
//     Size size,
//   ) {
//     final paint = Paint()
//       ..color = Colors.white
//       ..strokeWidth = 4
//       ..strokeCap =
//           StrokeCap.square;

//     final width = size.width;
//     final height = size.height;

//     // Bar 1
//     canvas.drawLine(
//       Offset(
//         width * .15,
//         height * .82,
//       ),
//       Offset(
//         width * .15,
//         height * .58,
//       ),
//       paint,
//     );

//     // Bar 2
//     canvas.drawLine(
//       Offset(
//         width * .38,
//         height * .82,
//       ),
//       Offset(
//         width * .38,
//         height * .38,
//       ),
//       paint,
//     );

//     // Bar 3
//     canvas.drawLine(
//       Offset(
//         width * .61,
//         height * .82,
//       ),
//       Offset(
//         width * .61,
//         height * .20,
//       ),
//       paint,
//     );

//     // Bar 4
//     canvas.drawLine(
//       Offset(
//         width * .84,
//         height * .82,
//       ),
//       Offset(
//         width * .84,
//         height * .08,
//       ),
//       paint,
//     );

//     // Bottom line
//     paint.color =
//         const Color(0xFF22C55E);

//     canvas.drawLine(
//       Offset(
//         width * .08,
//         height * .90,
//       ),
//       Offset(
//         width * .92,
//         height * .90,
//       ),
//       paint,
//     );
//   }

//   @override
//   bool shouldRepaint(
//     CustomPainter oldDelegate,
//   ) {
//     return false;
//   }
// }