// Language auto-detection and localization strings

enum AppLanguage { thai, english }

class AppStrings {
  static AppLanguage _currentLanguage = AppLanguage.thai;

  static AppLanguage get currentLanguage => _currentLanguage;

  static void setLanguage(AppLanguage language) {
    _currentLanguage = language;
  }

  // Auto-detect language from text
  static AppLanguage detectLanguage(String text) {
    if (text.isEmpty) return _currentLanguage;

    // Thai Unicode range: 0x0E00 - 0x0E7F
    final thaiRegex = RegExp(r'[\u0E00-\u0E7F]');
    if (thaiRegex.hasMatch(text)) {
      setLanguage(AppLanguage.thai);
      return AppLanguage.thai;
    }

    setLanguage(AppLanguage.english);
    return AppLanguage.english;
  }

  // ========== COMMON STRINGS ==========
  static String get appTitle =>
      _currentLanguage == AppLanguage.thai ? 'Smart Pantry' : 'Smart Pantry';

  // ========== INVENTORY LIST PAGE ==========
  static String get inventoryTitle =>
      _currentLanguage == AppLanguage.thai ? 'สินค้าคงคลัง' : 'Inventory';

  static String get subtitle => _currentLanguage == AppLanguage.thai
      ? 'จัดการสินค้าของคุณ'
      : 'Manage your items';

  static String get dashboard =>
      _currentLanguage == AppLanguage.thai ? 'แดชบอร์ด' : 'Dashboard';

  static String get totalItems =>
      _currentLanguage == AppLanguage.thai ? 'ทั้งหมด' : 'Total';

  static String get lowStock =>
      _currentLanguage == AppLanguage.thai ? 'สต็อกต่ำ' : 'Low Stock';

  static String get runningOut =>
      _currentLanguage == AppLanguage.thai ? 'ใกล้หมด' : 'Running Out';

  static String get searchHint => _currentLanguage == AppLanguage.thai
      ? 'ค้นหาสินค้า...'
      : 'Search items...';

  static String get noItems =>
      _currentLanguage == AppLanguage.thai ? 'ไม่มีสินค้า' : 'No items';

  static String get addItemsFirst => _currentLanguage == AppLanguage.thai
      ? 'เพิ่มสินค้าเพื่อเริ่มต้น'
      : 'Add items to get started';

  static String get noSearchResults => _currentLanguage == AppLanguage.thai
      ? 'ไม่พบผลลัพธ์'
      : 'No results found';

  static String get tryDifferentSearch => _currentLanguage == AppLanguage.thai
      ? 'ลองค้นหาอื่น'
      : 'Try different search';

  static String get edit =>
      _currentLanguage == AppLanguage.thai ? 'แก้ไข' : 'Edit';

  static String get delete =>
      _currentLanguage == AppLanguage.thai ? 'ลบ' : 'Delete';

  static String get deleteConfirm => _currentLanguage == AppLanguage.thai
      ? 'ลบสินค้านี้?'
      : 'Delete this item?';

  static String get yes => _currentLanguage == AppLanguage.thai ? 'ใช่' : 'Yes';

  static String get cancel =>
      _currentLanguage == AppLanguage.thai ? 'ยกเลิก' : 'Cancel';

  static String get deleted =>
      _currentLanguage == AppLanguage.thai ? 'ลบแล้ว' : 'Deleted';

  static String get undo =>
      _currentLanguage == AppLanguage.thai ? 'เลิกทำ' : 'Undo';

  // ========== ADD/EDIT ITEM PAGE ==========
  static String get addItem =>
      _currentLanguage == AppLanguage.thai ? 'เพิ่มสินค้า' : 'Add Item';

  static String get editItem =>
      _currentLanguage == AppLanguage.thai ? 'แก้ไขสินค้า' : 'Edit Item';

  static String get itemName =>
      _currentLanguage == AppLanguage.thai ? 'ชื่อสินค้า' : 'Item Name';

  static String get enterItemName => _currentLanguage == AppLanguage.thai
      ? 'กรุณากรอกชื่อสินค้า'
      : 'Enter item name';

  static String get itemNameMinLength => _currentLanguage == AppLanguage.thai
      ? 'ชื่อสินค้าต้องมีอย่างน้อย 2 ตัวอักษร'
      : 'Item name must be at least 2 characters';

  static String get barcode =>
      _currentLanguage == AppLanguage.thai ? 'บาร์โค้ด' : 'Barcode';

  static String get quantity =>
      _currentLanguage == AppLanguage.thai ? 'จำนวน' : 'Quantity';

  static String get enterQuantity =>
      _currentLanguage == AppLanguage.thai ? 'กรุณากรอกจำนวน' : 'Enter quantity';

  static String get quantityMustBeNumber => _currentLanguage == AppLanguage.thai
      ? 'จำนวนต้องเป็นตัวเลข'
      : 'Quantity must be a number';

  static String get quantityMustBeGreaterThanZero =>
      _currentLanguage == AppLanguage.thai
          ? 'จำนวนต้องมากกว่า 0'
          : 'Quantity must be greater than 0';

  static String get unit =>
      _currentLanguage == AppLanguage.thai ? 'หน่วย' : 'Unit';
  static String get quantityLabel =>
      _currentLanguage == AppLanguage.thai ? 'จำนวน' : 'Qty';
  static String get category =>
      _currentLanguage == AppLanguage.thai ? 'หมวดหมู่' : 'Category';

  static String get notes =>
      _currentLanguage == AppLanguage.thai ? 'หมายเหตุ' : 'Notes';

  static String get expiryDate =>
      _currentLanguage == AppLanguage.thai ? 'วันหมดอายุ' : 'Expiry Date';

  static String get save =>
      _currentLanguage == AppLanguage.thai ? 'บันทึก' : 'Save';

  // Categories and Units for dropdown options
  static String get categoryAll =>
      _currentLanguage == AppLanguage.thai ? 'ทั้งหมด' : 'All';

  static String get categoryFood =>
      _currentLanguage == AppLanguage.thai ? 'อาหาร' : 'Food';

  static String get categoryDrink =>
      _currentLanguage == AppLanguage.thai ? 'เครื่องดื่ม' : 'Drink';

  static String get categoryHousehold =>
      _currentLanguage == AppLanguage.thai ? 'ของใช้ในบ้าน' : 'Household';

  static String get categorySnack =>
      _currentLanguage == AppLanguage.thai ? 'ขนมและของหนำ' : 'Snack';

  static String get unitPcs =>
      _currentLanguage == AppLanguage.thai ? 'ชิ้น' : 'pcs';

  static String get unitBottle =>
      _currentLanguage == AppLanguage.thai ? 'ขวด' : 'bottle';

  static String get unitPack =>
      _currentLanguage == AppLanguage.thai ? 'แพ็ก' : 'pack';

  static String get unitKg =>
      _currentLanguage == AppLanguage.thai ? 'กิโลกรัม' : 'kg';

  static String get scanBarcode =>
      _currentLanguage == AppLanguage.thai ? 'สแกนบาร์โค้ด' : 'Scan Barcode';

  static String get lookupProduct =>
      _currentLanguage == AppLanguage.thai ? 'ค้นหาสินค้า' : 'Lookup Product';

  static String get productNotFoundFromBarcode => _currentLanguage == AppLanguage.thai
      ? 'ไม่พบสินค้าจากบาร์โค้ด'
      : 'Product not found from barcode';

  static String get lookupFailed =>
      _currentLanguage == AppLanguage.thai ? 'ค้นหาล้มเหลว' : 'Lookup failed';

  static String get takePhoto =>
      _currentLanguage == AppLanguage.thai ? 'ถ่ายรูป' : 'Take photo';

  static String get chooseFromGallery =>
      _currentLanguage == AppLanguage.thai ? 'เลือกรูป' : 'Choose from gallery';

  static String get extractTextFromImage => _currentLanguage == AppLanguage.thai
      ? 'ดึงข้อความจากรูป'
      : 'Extract text from image';

  static String get extractingText =>
      _currentLanguage == AppLanguage.thai ? 'กำลังดึงข้อความ...' : 'Extracting text...';

  static String get textExtractionFailed => _currentLanguage == AppLanguage.thai
      ? 'ดึงข้อความไม่สำเร็จ'
      : 'Text extraction failed';

  static String get identifyWithAI =>
      _currentLanguage == AppLanguage.thai ? 'ระบุสินค้าด้วย AI' : 'Identify with AI';

  static String get identifyingItem =>
      _currentLanguage == AppLanguage.thai ? 'กำลังระบุสินค้า...' : 'Identifying item...';

  static String get aiIdentificationFailed => _currentLanguage == AppLanguage.thai
      ? 'ระบุสินค้าไม่สำเร็จ'
      : 'Item identification failed';

  static String get confidenceLabel =>
      _currentLanguage == AppLanguage.thai ? 'ความมั่นใจ' : 'Confidence';

  static String get aiProviderGemini =>
      _currentLanguage == AppLanguage.thai ? 'Gemini' : 'Gemini';

  static String get aiProviderOpenAi =>
      _currentLanguage == AppLanguage.thai ? 'OpenAI' : 'OpenAI';

  static String get aiSummaryTitle =>
      _currentLanguage == AppLanguage.thai ? 'สรุปจาก AI' : 'AI Summary';

  static String get durationLabel =>
      _currentLanguage == AppLanguage.thai ? 'ระยะเวลา' : 'Duration';

  static String get tipsLabel =>
      _currentLanguage == AppLanguage.thai ? 'คำแนะนำ' : 'Tips';

  static String get aiSummaryFailed => _currentLanguage == AppLanguage.thai
      ? 'สรุปด้วย AI ไม่สำเร็จ (ยังบันทึกได้)'
      : 'AI summary failed (item can still be saved)';

  static String get summarizeWithAi => _currentLanguage == AppLanguage.thai
      ? 'สรุปด้วย AI'
      : 'Summarize with AI';

  static String get summarizingWithAi => _currentLanguage == AppLanguage.thai
      ? 'กำลังสรุปด้วย AI...'
      : 'Summarizing with AI...';

  static String get invalidForm => _currentLanguage == AppLanguage.thai
      ? 'กรุณากรอกข้อมูลให้ครบ'
      : 'Please fill all fields';

  static String get itemAdded =>
      _currentLanguage == AppLanguage.thai ? 'เพิ่มสินค้าแล้ว' : 'Item added';

  static String get itemUpdated =>
      _currentLanguage == AppLanguage.thai ? 'อัปเดตแล้ว' : 'Item updated';

  // ========== BARCODE SCANNER PAGE ==========
  static String get scanBarcodeTitle =>
      _currentLanguage == AppLanguage.thai ? 'สแกนบาร์โค้ด' : 'Scan Barcode';

  static String get pointCamera => _currentLanguage == AppLanguage.thai
      ? 'ชี้กล้องไปที่บาร์โค้ด'
      : 'Point camera at barcode';

  // ========== AI CHAT PAGE ==========
  static String get aiMenuAssistant => _currentLanguage == AppLanguage.thai
      ? 'ผู้ช่วยเสนอเมนู AI'
      : 'AI Menu Assistant';

  static String get smartKitchenHelper => _currentLanguage == AppLanguage.thai
      ? 'ผู้ช่วยห้องครัวอัจฉริยะของคุณ'
      : 'Your smart kitchen helper';

  static String get welcomeToAIChef => _currentLanguage == AppLanguage.thai
      ? 'ยินดีต้อนรับสู่ AI Chef! 👨‍🍳'
      : 'Welcome to AI Chef! 👨‍🍳';

  static String get askAboutRecipes => _currentLanguage == AppLanguage.thai
      ? 'ถามฉันเกี่ยวกับสินค้าในห้องเก็บของของคุณ'
      : 'Ask me anything about your pantry items';

  static String get whatCanICook => _currentLanguage == AppLanguage.thai
      ? 'ฉันจะทำอะไรได้บ้าง?'
      : 'What can I cook?';

  static String get healthyRecipes => _currentLanguage == AppLanguage.thai
      ? 'สูตรอาหารสุขภาพ'
      : 'Healthy recipes';

  static String get quickMeals =>
      _currentLanguage == AppLanguage.thai ? 'มื้ออาหารด่วน' : 'Quick meals';

  static String get dessertIdeas =>
      _currentLanguage == AppLanguage.thai ? 'ไอเดียขนมหวาน' : 'Dessert ideas';

  static String get askAboutRecipesHint => _currentLanguage == AppLanguage.thai
      ? 'ถามเกี่ยวกับสูตรอาหาร วัตถุดิบ...'
      : 'Ask about recipes, ingredients...';

  static String get pantryEmpty => _currentLanguage == AppLanguage.thai
      ? 'ห้องเก็บของของคุณว่างเปล่า เพิ่มสินค้าก่อนน่ะ! 🛒'
      : 'Your pantry is empty. Please add some items first! 🛒';

  static String get thinking => _currentLanguage == AppLanguage.thai
      ? 'กำลังคิด... 🤔'
      : 'Thinking... 🤔';

  static String get aiChefIsThinking => _currentLanguage == AppLanguage.thai
      ? 'AI Chef กำลังคิด...'
      : 'AI Chef is thinking...';

  static String get connectionIssue => _currentLanguage == AppLanguage.thai
      ? '⚠️ มีปัญหาการเชื่อมต่อ แสดงข้อเสนอแบบออฟไลน์จากสินค้าของคุณ'
      : '⚠️ Connection issue. Showing offline suggestions based on your ingredients.';

  static String get menuSuggestions => _currentLanguage == AppLanguage.thai
      ? '✨ เมนูแนะนำจากวัตถุดิบที่คุณมี:'
      : '✨ Menu Suggestions from Your Ingredients:';

  static String get quickMealSuggestion => _currentLanguage == AppLanguage.thai
      ? '🍲 ต้มจืดหรือต้มแซ่บ'
      : '🍲 Quick Soup or Spicy Soup';

  static String get quickMealReason => _currentLanguage == AppLanguage.thai
      ? 'ใช้โปรตีนที่มี พร้อมเครื่องต่างๆ'
      : 'Use protein with various seasonings';

  static String get stirFrySuggestion => _currentLanguage == AppLanguage.thai
      ? '🥘 ผัดกระทะผัก'
      : '🥘 Vegetable Stir Fry';

  static String get stirFryReason => _currentLanguage == AppLanguage.thai
      ? 'ผัดผักหลากชนิดกับเครื่องปรุง'
      : 'Stir fry various vegetables with seasonings';

  static String get riceNoodleSuggestion => _currentLanguage == AppLanguage.thai
      ? '🍚 ข้าวหรือเส้นผัด'
      : '🍚 Fried Rice or Noodles';

  static String get riceNoodleReason => _currentLanguage == AppLanguage.thai
      ? 'เป็นเมนูสำคัญใช้วัตถุดิบหลากหลาย'
      : 'Main dish using various ingredients';

  static String get saladSuggestion => _currentLanguage == AppLanguage.thai
      ? '🍽️ สลัดหรือจานอาหารรวม'
      : '🍽️ Salad or Mixed Dish';

  static String get saladReason => _currentLanguage == AppLanguage.thai
      ? 'รวมวัตถุดิบต่างๆ เป็นจานเดียว'
      : 'Combine ingredients into one plate';

  static String get downloadMoreIngredientsHint =>
      _currentLanguage == AppLanguage.thai
      ? '💡 ลองค้นหาวัตถุดิบเพิ่มเติมสำหรับเมนูหลากหลายมากขึ้น!'
      : '💡 Try searching more ingredients for more menu options!';

  // ========== SETTINGS/THEME ==========
  static String get darkMode =>
      _currentLanguage == AppLanguage.thai ? 'โหมดมืด' : 'Dark Mode';

  static String get lightMode =>
      _currentLanguage == AppLanguage.thai ? 'โหมดสว่าง' : 'Light Mode';

  static String get changeLanguage =>
      _currentLanguage == AppLanguage.thai ? 'เปลี่ยนภาษา' : 'Change Language';

  static String get thai =>
      _currentLanguage == AppLanguage.thai ? 'ไทย' : 'Thai';

  static String get english =>
      _currentLanguage == AppLanguage.thai ? 'อังกฤษ' : 'English';

  // ========== ERROR MESSAGES ==========
  static String get errorLoading => _currentLanguage == AppLanguage.thai
      ? 'เกิดข้อผิดพลาดในการโหลด'
      : 'Error loading data';

  static String get tryAgain =>
      _currentLanguage == AppLanguage.thai ? 'ลองใหม่' : 'Try Again';

  static String get noInternet => _currentLanguage == AppLanguage.thai
      ? 'ไม่มีการเชื่อมต่ออินเทอร์เน็ต'
      : 'No internet connection';

  static String get permissionRequired => _currentLanguage == AppLanguage.thai
      ? 'จำเป็นต้องได้รับอนุญาต'
      : 'Permission required';

  static String get cameraPermission => _currentLanguage == AppLanguage.thai
      ? 'ต้องการอนุญาตใช้กล้อง'
      : 'Camera permission required';

  // ========== ITEM DETAILS ==========
  static String get itemDetails => _currentLanguage == AppLanguage.thai
      ? 'รายละเอียดสินค้า'
      : 'Item Details';

  static String get createdAt =>
      _currentLanguage == AppLanguage.thai ? 'สร้างเมื่อ' : 'Created';

  static String get updatedAt =>
      _currentLanguage == AppLanguage.thai ? 'อัปเดตเมื่อ' : 'Updated';
}
