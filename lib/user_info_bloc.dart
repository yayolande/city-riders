import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserState());

  void setUserRegistrationDetails(UserState user) => emit(user);
  void reset() => emit(UserState());
  void setDriverStatus(bool isDriver) {
    state.isDriver = isDriver;
    emit(state);
  }

  void setDriverDetails(String carModel, String carStanding) {
    state.carModel = carModel;
    state.carStanding = carStanding;

    emit(state);
  }

  void setUserAuth(User user) {
    state.user = user;
    emit(state);
  }
}

class UserState {
  UserState();

  User? user;

  int id = -1;
  String username = "";
  String password = "";
  String email = "";
  bool isDriver = false;

  String carModel = "";
  String carStanding = "";
}
