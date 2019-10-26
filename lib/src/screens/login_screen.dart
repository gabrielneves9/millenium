import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:millenium/src/blocs/authentication_bloc.dart';
import 'package:millenium/src/blocs/usuario_bloc.dart';
import 'package:millenium/src/components/form/animated_button.dart';
import 'package:millenium/src/components/form/circular_button.dart';
import 'package:millenium/src/components/utils/custom_divider.dart';
import 'package:millenium/src/components/logo.dart';
import 'package:millenium/src/components/form/text_field.dart';
import 'package:millenium/src/models/page_state.dart';
import 'package:millenium/src/models/usuario.dart';
import 'package:millenium/src/screens/jogador/jogador_home_screen.dart';
import 'package:millenium/src/screens/mestre/mestre_home_screen.dart';
import 'package:millenium/src/util/util.dart';
import 'package:millenium/src/validators/usuario_validator.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin, UsuarioValidator {
  final _userBloc = BlocProvider.getBloc<UsuarioBloc>();
  final _bloc = BlocProvider.getBloc<AuthenticationBloc>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _bloc.stateStream.listen((state) async {
      switch (state) {
        case PageState.SUCCESS:
          Usuario usuario = await _userBloc.obterUsuario();
          if (usuario.isAdmin) {
            navigateTo(
              context,
              MestreHomeScreen(
                usuario: usuario,
              ),
            );
          } else {
            navigateTo(
              context,
              JogadorHomeScreen(
                usuario: usuario,
              ),
            );
          }
          break;
        case PageState.FAILED:
          showMessage(
            key: _scaffoldKey,
            mensagem: "Erro ao autenticar.\nVerifique sua conexão.",
          );
          _animationController.reset();
          break;
        default:
      }
    });
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: <Widget>[
                    Logo(),
                    CustomTextField(
                      stream: _bloc.emailStream,
                      sink: _bloc.emailSink,
                      labelText: "Email",
                    ),
                    CustomTextField(
                      stream: _bloc.senhaStream,
                      sink: _bloc.senhaSink,
                      labelText: "Senha",
                      obscureText: true,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: StreamBuilder<bool>(
                          stream: _bloc.isFormValidate,
                          builder: (context, snapshot) {
                            return AnimatedButton(
                              text: "ENTRAR",
                              controller: _animationController.view,
                              onPressed: snapshot.hasData
                                  ? () {
                                      _onFormSubmitted();
                                    }
                                  : null,
                            );
                          }),
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(child: CustomDivider()),
                        Expanded(
                          child: Text(
                            "ou",
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(child: CustomDivider())
                      ],
                    ),
                    CircularButton(
                      text: "CRIAR CONTA",
                      onPressed: () {
                        Navigator.of(context).pushNamed("/cadastroContaScreen");
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onFormSubmitted() {
    _animationController.forward();
    _bloc.efetuarLogin();
  }
}
