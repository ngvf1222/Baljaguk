import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: SignUpForm()
    );
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final emailController=TextEditingController();
  final pwController=TextEditingController();
  final supabase=Supabase.instance.client;
  String message='';

  Future<void> onPushed() async{
    try{
      final res=await supabase.auth.signUp(
        email:emailController.text,
        password: pwController.text,
      );
      print(res);
      message='가입이 완료되었습니다.';
    } on AuthApiException catch(e) {
      switch(e.code){
        case 'user_already_exists':
          message='이미 가입된 유저입니다.';
          break;
        case 'validation_failed':
          message='이메일 혹은 비밀번호가 비어 있습니다.';
          break;
        case 'email_exists':
          message='사용중인 이메일입니다.';
          break;
        case 'over_request_rate_limit':
        case 'over_email_send_rate_limit':
          message='인증요청이 너무 잦습니다.\n다음에 다시 시도하세요.';
          break;
        default:
          message='에러, 잠시 후 다시 시도해주세요.';
      }
    } on AuthWeakPasswordException catch(e){
      message='비밀번호가 약합니다\n${e.message}';
    }
    setState(() {

    });
  }

  @override
  void dispose() {
    emailController.dispose();
    pwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      child: Form(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Email'),
                SizedBox(
                    width: 200,
                    child:TextFormField(
                      controller: emailController,
                    )
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Password'),
                SizedBox(
                    width:200,
                    child:TextFormField(
                      obscureText: true,
                      controller: pwController,
                    )
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Text(message),
            TextButton(
              child: Container(
                  width:250,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child:Text(
                    'SignUp',
                    style: TextStyle(
                        color:Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600
                    ),
                  )
              ),
              onPressed: onPushed,
            )
          ],
        ),
      ),
    );
  }
}