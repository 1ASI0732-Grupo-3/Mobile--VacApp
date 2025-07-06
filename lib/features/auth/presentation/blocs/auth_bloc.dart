import 'package:vacapp/features/auth/data/repositories/auth_repository.dart';
import 'package:vacapp/features/auth/domain/entitites/user.dart';
import 'package:vacapp/features/auth/presentation/blocs/auth_event.dart';
import 'package:vacapp/features/auth/presentation/blocs/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(InitialAuthState()) {
    on<LoginEvent>((event, emit) async {
      emit(LoadingAuthState());
      try {
        final User user = await authRepository.login(
          usernameOrEmail: event.usernameOrEmail,
          password: event.password,
        );
        emit(SuccessLoginState(user: user));
      } catch (e) {
        emit(FailureState(errorMessage: e.toString()));
      }
    });

    on<SignUpEvent>((event, emit) async {
      emit(LoadingAuthState());
      try {
        final User user = await authRepository.signUp(
          username: event.username,
          password: event.password,
          email: event.email,
        );
        emit(SuccessRegisterState(user: user));
      } catch (e) {
        emit(FailureState(errorMessage: e.toString()));
      }
    });
  }
}