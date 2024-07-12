import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PurchaseController extends GetxController {
  var purchasedItems = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadPurchasedItems();
  }

  void addPurchasedItem(String itemId) async {
    purchasedItems.add(itemId);
    await _savePurchasedItems();
  }

  bool isPurchased(String itemId) {
    return purchasedItems.contains(itemId);
  }

  void _loadPurchasedItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? items = prefs.getStringList('purchasedItems');
    if (items != null) {
      purchasedItems.addAll(items);
    }
  }

  Future<void> _savePurchasedItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('purchasedItems', purchasedItems.toList());
  }
}
