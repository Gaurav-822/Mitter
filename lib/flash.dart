import 'package:morse_lighter/toast.dart';
import 'package:torch_light/torch_light.dart';

void turnOnFlash() async {
  try {
    await TorchLight.enableTorch();
  } on Exception catch (_) {
    showToastMessage("Flashlight Not Found");
  }
}

void turnOffFlash() async {
  try {
    await TorchLight.disableTorch();
  } on Exception catch (_) {
    showToastMessage("Flashlight Not Found");
  }
}

void strobber(int freq, bool br) {
  if (br) {
    Future<void> toggleLight() async {
      while (br) {
        turnOnFlash();
        await Future.delayed(Duration(milliseconds: (1000 ~/ freq) ~/ 2));
        turnOffFlash();
        await Future.delayed(Duration(milliseconds: (1000 ~/ freq) ~/ 2));
      }
    }

    toggleLight();
  }
}

Future<void> delay(int millisec) async {
  await Future.delayed(Duration(milliseconds: millisec));
}
