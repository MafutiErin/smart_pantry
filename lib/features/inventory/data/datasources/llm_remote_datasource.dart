import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/ai/ai_provider.dart';
import '../../../../core/ai/ai_provider_service.dart';
import '../../../../core/network/gemini_dio_client.dart';
import '../../../../core/network/openai_dio_client.dart';

abstract class LlmRemoteDataSource {
  Future<String> suggestMenuFromPantry(
    List<String> itemNames,
    String userMessage,
  );

  Future<Map<String, String>> suggestItemDetails(
    String itemName,
    String? category,
    String? notes,
  );

  Future<Map<String, String>> identifyItemFromLabel(String ocrText);
}

class LlmRemoteDataSourceImpl implements LlmRemoteDataSource {
  final GeminiDioClient geminiClient;
  final OpenAIDioClient openaiClient;
  final AiProviderService providerService;

  LlmRemoteDataSourceImpl(
    this.geminiClient,
    this.openaiClient,
    this.providerService,
  );

  @override
  Future<String> suggestMenuFromPantry(
    List<String> itemNames,
    String userMessage,
  ) async {
    try {
      final joined = itemNames.join(', ');
      final isThaiLanguage = _isThaiText(userMessage);

      final provider = await providerService.getProvider();

      if (provider == AiProvider.openai) {
        final result = await _suggestMenuWithOpenAi(
          ingredientsJoined: joined,
          itemNames: itemNames,
          userMessage: userMessage,
          isThaiLanguage: isThaiLanguage,
        );
        return result;
      }

      try {
        final response = await geminiClient.dio.post(
          '/models/gemini-2.5-flash:generateContent',
          data: {
            'contents': [
              {
                'parts': [
                  {'text': _buildPrompt(joined, userMessage, isThaiLanguage)},
                ],
              },
            ],
            'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 4000},
          },
        );

        final result = _extractGeminiResponse(response.data);

        if (result.isEmpty) {
          return _generateFallbackResponse(
            itemNames,
            userMessage,
            isThaiLanguage,
          );
        }

        return result;
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        if (status == 429) {
          try {
            return await _suggestMenuWithOpenAi(
              ingredientsJoined: joined,
              itemNames: itemNames,
              userMessage: userMessage,
              isThaiLanguage: isThaiLanguage,
            );
          } catch (_) {
            rethrow;
          }
        }
        rethrow;
      }
    } on DioException catch (e) {
      final isThai = _isThaiText(userMessage);

      final status = e.response?.statusCode;
      if (status == 429) {
        return isThai
            ? 'ขณะนี้ AI ใช้งานเกินโควต้า/ถูกจำกัดการเรียกใช้งาน (429) กรุณารอสักครู่ หรือสลับผู้ให้บริการ AI (OpenAI) และตรวจสอบแพ็กเกจ/โควต้าของ API key'
            : 'AI quota/rate limit exceeded (429). Please wait, or switch AI provider (OpenAI) and verify your API key quota/billing.';
      }

      // Handle specific error types
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return _generateFallbackResponse(
          itemNames,
          userMessage,
          isThai,
          reason: isThai
              ? 'การเชื่อมต่อไม่เสถียร - ใช้ข้อเสนอขั้นสูง'
              : 'Network unstable - using smart suggestions',
        );
      }

      // Always fallback instead of throwing so UI can show offline suggestions.
      final reason = status == 401 || status == 403
          ? (isThai
              ? 'API Key ไม่ถูกต้อง/ไม่มีสิทธิ์ - ใช้ข้อเสนอออฟไลน์'
              : 'Invalid API key/permission - using offline suggestions')
          : (isThai
              ? 'เกิดข้อผิดพลาดจาก AI - ใช้ข้อเสนอออฟไลน์'
              : 'AI error - using offline suggestions');

      return _generateFallbackResponse(
        itemNames,
        userMessage,
        isThai,
        reason: reason,
      );
    } catch (e) {
      // Fallback response on any error
      return _generateFallbackResponse(
        itemNames,
        userMessage,
        _isThaiText(userMessage),
        reason: _isThaiText(userMessage)
            ? 'AI ออฟไลน์ชั่วคราว - ใช้ข้อเสนอออฟไลน์'
            : 'AI temporarily offline - using offline suggestions',
      );
    }
  }

  Future<String> _suggestMenuWithOpenAi({
    required String ingredientsJoined,
    required List<String> itemNames,
    required String userMessage,
    required bool isThaiLanguage,
  }) async {
    final response = await openaiClient.dio.post(
      '/chat/completions',
      data: {
        'model': 'gpt-4o-mini',
        'temperature': 0.7,
        'max_tokens': 1000,
        'messages': [
          {
            'role': 'system',
            'content': isThaiLanguage
                ? 'คุณเป็นผู้ช่วยแนะนำเมนูอาหารสำหรับแอป Smart Pantry'
                : 'You are a menu recommendation assistant for the Smart Pantry app.',
          },
          {
            'role': 'user',
            'content': _buildPrompt(ingredientsJoined, userMessage, isThaiLanguage),
          },
        ],
      },
    );

    final result = _extractOpenAiText(response.data);
    if (result.isEmpty) {
      return _generateFallbackResponse(itemNames, userMessage, isThaiLanguage);
    }
    return result;
  }

  String _extractOpenAiText(dynamic responseData) {
    try {
      final data = responseData as Map<String, dynamic>?;
      if (data == null) return '';

      final choices = data['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) return '';

      final first = choices.first as Map<String, dynamic>?;
      if (first == null) return '';

      final message = first['message'] as Map<String, dynamic>?;
      if (message == null) return '';

      final content = message['content'] as String?;
      if (content == null) return '';

      return content.trim();
    } catch (_) {
      return '';
    }
  }

  /// Check if text contains Thai characters
  bool _isThaiText(String text) {
    if (text.isEmpty) return true; // Default to Thai
    final thaiRegex = RegExp(r'[\u0E00-\u0E7F]');
    return thaiRegex.hasMatch(text);
  }

  /// Build prompt in appropriate language
  String _buildPrompt(
    String ingredients,
    String userMessage,
    bool isThaiLanguage,
  ) {
    if (isThaiLanguage) {
      return '''
คุณเป็นผู้ช่วยแนะนำเมนูอาหารสำหรับแอป Smart Pantry

วัตถุดิบที่มี:
$ingredients

คำถามของผู้ใช้:
$userMessage

งานของคุณ:
1) แนะนำ 3 เมนูที่ทำได้จากของที่มี
2) แต่ละเมนูให้บอกเหตุผลสั้น ๆ
3) ถ้าของไม่พอ ให้บอกของที่ขาดเพิ่มแบบสั้น
4) ตอบเป็นภาษาไทย อ่านง่าย กระชับ
5) จัดรูปแบบเป็นหัวข้อย่อย
''';
    } else {
      return '''
You are a menu recommendation assistant for the Smart Pantry app.

Available ingredients:
$ingredients

User question:
$userMessage

Your tasks:
1) Suggest 3 menus that can be made from available ingredients
2) For each menu, provide a brief reason
3) If ingredients are missing, mention what's needed
4) Respond in English, easy to read, concise
5) Format as bullet points
''';
    }
  }

  /// Extract text safely from Gemini API response with fallback
  String _extractGeminiResponse(dynamic responseData) {
    try {
      final data = responseData as Map<String, dynamic>?;
      if (data == null) return '';

      final candidates = data['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) return '';

      final firstCandidate = candidates.first as Map<String, dynamic>?;
      if (firstCandidate == null) return '';

      final content = firstCandidate['content'] as Map<String, dynamic>?;
      if (content == null) return '';

      final parts = content['parts'] as List<dynamic>?;
      if (parts == null || parts.isEmpty) return '';

      final firstPart = parts.first as Map<String, dynamic>?;
      if (firstPart == null) return '';

      final text = firstPart['text'] as String?;

      return (text != null && text.trim().isNotEmpty) ? text.trim() : '';
    } catch (e) {
      return '';
    }
  }

  /// Generate smart fallback response using available ingredients
  String _generateFallbackResponse(
    List<String> itemNames,
    String userMessage,
    bool isThaiLanguage, {
    String? reason,
  }) {
    final buffer = StringBuffer();

    if (reason != null) {
      buffer.writeln('$reason\n');
    }

    if (isThaiLanguage) {
      buffer.writeln('✨ เมนูแนะนำจากวัตถุดิบที่คุณมี:\n');

      // Generate basic suggestions based on ingredients
      final suggestions = _generateSmartSuggestions(
        itemNames,
        userMessage,
        isThaiLanguage,
      );
      for (final (index, suggestion) in suggestions.indexed) {
        buffer.writeln('${index + 1}. ${suggestion['title']}');
        buffer.writeln('   📝 ${suggestion['reason']}\n');
      }

      buffer.writeln('💡 ลองค้นหาวัตถุดิบเพิ่มเติมสำหรับเมนูหลากหลายมากขึ้น!');
    } else {
      buffer.writeln('✨ Menu Suggestions from Your Ingredients:\n');

      final suggestions = _generateSmartSuggestions(
        itemNames,
        userMessage,
        isThaiLanguage,
      );
      for (final (index, suggestion) in suggestions.indexed) {
        buffer.writeln('${index + 1}. ${suggestion['title']}');
        buffer.writeln('   📝 ${suggestion['reason']}\n');
      }

      buffer.writeln(
        '💡 Try searching more ingredients for more menu options!',
      );
    }

    return buffer.toString();
  }

  /// Generate smart suggestions based on ingredient patterns
  List<Map<String, String>> _generateSmartSuggestions(
    List<String> items,
    String userMessage,
    bool isThaiLanguage,
  ) {
    final itemsLower = items.map((i) => i.toLowerCase()).toList();
    final msgLower = userMessage.toLowerCase();
    final suggestions = <Map<String, String>>[];

    final wantsSpicy = msgLower.contains('เผ็ด') ||
        msgLower.contains('spicy') ||
        msgLower.contains('hot');
    final wantsQuick = msgLower.contains('ด่วน') ||
        msgLower.contains('เร็ว') ||
        msgLower.contains('quick') ||
        msgLower.contains('fast');
    final wantsHealthy = msgLower.contains('สุขภาพ') ||
        msgLower.contains('คลีน') ||
        msgLower.contains('healthy') ||
        msgLower.contains('clean');
    final wantsDessert = msgLower.contains('ของหวาน') ||
        msgLower.contains('dessert') ||
        msgLower.contains('sweet');

    if (wantsSpicy) {
      suggestions.add({
        'title': isThaiLanguage ? '🌶️ ผัดเผ็ดหรือแกงเผ็ด' : '🌶️ Spicy Stir Fry or Curry',
        'reason': isThaiLanguage
            ? 'ปรับระดับความเผ็ดตามชอบ ใช้โปรตีน/ผักที่มีได้'
            : 'Adjust spiciness to your taste using your available protein/veggies',
      });
    }

    if (wantsQuick) {
      suggestions.add({
        'title': isThaiLanguage ? '⏱️ เมนูผัดจานด่วน' : '⏱️ Quick Stir Fry',
        'reason': isThaiLanguage
            ? 'ใช้เวลาน้อย ทำได้ไว เหมาะกับมื้อเร่งด่วน'
            : 'Fast to cook and great for a quick meal',
      });
    }

    if (wantsHealthy) {
      suggestions.add({
        'title': isThaiLanguage ? '🥗 สลัดหรือยำแบบเบาๆ' : '🥗 Light Salad',
        'reason': isThaiLanguage
            ? 'เน้นผัก โปรตีน และปรุงรสเบาๆ'
            : 'Focus on veggies + protein with light seasoning',
      });
    }

    if (wantsDessert) {
      suggestions.add({
        'title': isThaiLanguage ? '🍯 ของหวานง่ายๆ' : '🍯 Simple Dessert',
        'reason': isThaiLanguage
            ? 'ถ้ามีผลไม้/นมหรือไข่ ลองทำเมนูของหวานง่ายๆ'
            : 'If you have fruits/dairy/eggs, try a simple dessert',
      });
    }

    // Check for protein-based suggestions
    if (_hasAny(itemsLower, [
      'ไก่',
      'เนื้อ',
      'ปลา',
      'ไข่',
      'หมู',
      'chicken',
      'beef',
      'fish',
      'egg',
      'pork',
    ])) {
      suggestions.add({
        'title': isThaiLanguage
            ? '🍲 ต้มจืดหรือต้มแซ่บ'
            : '🍲 Quick Soup or Spicy Soup',
        'reason': isThaiLanguage
            ? 'ใช้โปรตีนที่มี พร้อมเครื่องต่างๆ'
            : 'Use protein with various seasonings',
      });
    }

    // Check for vegetable-based suggestions
    if (_hasAny(itemsLower, [
      'ผัก',
      'กะหล่ำ',
      'มะเขือ',
      'พริก',
      'หอม',
      'vegetable',
      'cabbage',
      'eggplant',
      'chili',
      'onion',
    ])) {
      suggestions.add({
        'title': isThaiLanguage ? '🥘 ผัดกระทะผัก' : '🥘 Vegetable Stir Fry',
        'reason': isThaiLanguage
            ? 'ผัดผักหลากชนิดกับเครื่องปรุง'
            : 'Stir fry various vegetables with seasonings',
      });
    }

    // Check for rice/noodle-based suggestions
    if (_hasAny(itemsLower, [
      'ข้าว',
      'นูดล',
      'พาสต้า',
      'ก๋วยเตี๋ยว',
      'rice',
      'noodle',
      'pasta',
    ])) {
      suggestions.add({
        'title': isThaiLanguage
            ? '🍚 ข้าวหรือเส้นผัด'
            : '🍚 Fried Rice or Noodles',
        'reason': isThaiLanguage
            ? 'เป็นเมนูสำคัญใช้วัตถุดิบหลากหลาย'
            : 'Main dish using various ingredients',
      });
    }

    // If no specific matches, provide generic suggestion
    if (suggestions.isEmpty) {
      suggestions.add({
        'title': isThaiLanguage
            ? '🍽️ สลัดหรือจานอาหารรวม'
            : '🍽️ Salad or Mixed Dish',
        'reason': isThaiLanguage
            ? 'รวมวัตถุดิบต่างๆ เป็นจานเดียว'
            : 'Combine ingredients into one plate',
      });
    }

    return suggestions.take(3).toList();
  }

  /// Check if list contains any of the keywords
  bool _hasAny(List<String> items, List<String> keywords) {
    return items.any(
      (item) => keywords.any((keyword) => item.contains(keyword)),
    );
  }

  @override
  Future<Map<String, String>> suggestItemDetails(
    String itemName,
    String? category,
    String? notes,
  ) async {
    try {
      // Determine language from item name
      final isThaiLanguage = _isThaiText(itemName);

      final provider = await providerService.getProvider();

      if (provider == AiProvider.openai) {
        final response = await openaiClient.dio.post(
          '/chat/completions',
          data: {
            'model': 'gpt-4o-mini',
            'temperature': 0.6,
            'max_tokens': 500,
            'response_format': {'type': 'json_object'},
            'messages': [
              {
                'role': 'system',
                'content': isThaiLanguage
                    ? 'คุณเป็นผู้เชี่ยวชาญด้านวัตถุดิบอาหาร'
                    : 'You are a food ingredient classification expert.',
              },
              {
                'role': 'user',
                'content': _buildItemDetailPrompt(
                  itemName,
                  category,
                  notes,
                  isThaiLanguage,
                ),
              },
            ],
          },
        );

        final result = _extractOpenAiText(response.data);
        if (result.isEmpty) {
          return _generateFallbackItemDetails(itemName, isThaiLanguage);
        }
        return _parseItemDetailResponse(result, isThaiLanguage);
      }

      final response = await geminiClient.dio.post(
        '/models/gemini-2.5-flash:generateContent',
        data: {
          'contents': [
            {
              'parts': [
                {
                  'text': _buildItemDetailPrompt(
                    itemName,
                    category,
                    notes,
                    isThaiLanguage,
                  ),
                },
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.6,
            'maxOutputTokens': 500,
            'responseMimeType': 'application/json',
          },
        },
      );

      final result = _extractGeminiResponse(response.data);

      if (result.isEmpty) {
        return _generateFallbackItemDetails(itemName, isThaiLanguage);
      }

      // Parse the response to extract suggestions
      return _parseItemDetailResponse(result, isThaiLanguage);
    } on DioException {
      return _generateFallbackItemDetails(itemName, _isThaiText(itemName));
    } catch (_) {
      return _generateFallbackItemDetails(itemName, _isThaiText(itemName));
    }
  }

  /// Build prompt for item detail suggestions with JSON format requirement
  String _buildItemDetailPrompt(
    String itemName,
    String? category,
    String? notes,
    bool isThaiLanguage,
  ) {
    if (isThaiLanguage) {
      return '''
คุณเป็นผู้เชี่ยวชาญด้านวัตถุดิบอาหาร จำแนกวัตถุดิบชื่อ: '$itemName'

ตอบกลับมาเป็นรูปแบบ JSON เท่านั้น ไม่มีข้อความอื่น โดยมี key ดังนี้:

category: เลือก 1 จากรายการนี้เท่านั้น: 
  - เนื้อสัตว์ (อาหารสด: เนื้อไก่, หมู, เนื้อสัตว์อื่น)
  - ผัก (พืชสดใจ: ผักทั่วไป)
  - ผลไม้ (ผลไม้สด)
  - อาหารแห้ง (ข้าว, พาสต้า, เมล็ดพืช)
  - เครื่องปรุง (เกลือ, น้ำตาล, สปายซ์)
  - นมและไข่ (ไข่, นม, ผลิตภัณฑ์นม)
  - ของกระป๋อง (ของอนุรักษ์)

duration: ระยะเวลาเก็บได้ เช่น "3-5 วัน" หรือ "1-2 เดือน"

tips: วิธีเก็บรักษาที่ถูกต้องและเป็นธรรมชาติ สั้น กระชับ เช่น "เก็บในช่องแช่แข็ง" หรือ "วางในตู้เย็น"

ตัวอย่าง JSON response:
{
  "category": "เนื้อสัตว์",
  "duration": "3-5 วัน",
  "tips": "เก็บในช่องแช่แข็งตู้เย็น"
}
''';
    } else {
      return '''
You are a food ingredient classification expert. Classify ingredient: '$itemName'

Respond ONLY in JSON format, no other text. Include these keys:

category: Choose exactly ONE from this list ONLY:
  - Meat (fresh meat: chicken, pork, beef)
  - Vegetables (fresh produce: greens, vegetables)
  - Fruits (fresh fruit)
  - Grains & Dry (rice, pasta, seeds)
  - Spices & Seasonings (salt, sugar, spices)
  - Dairy & Eggs (milk, eggs, dairy products)
  - Canned & Preserved (preserved foods)

duration: Storage time estimate, e.g. "3-5 days" or "1-2 months"

tips: Natural, short, and practical storage instructions e.g. "Keep in freezer" or "Refrigerate after opening"

Example JSON response:
{
  "category": "Meat",
  "duration": "3-5 days",
  "tips": "Store in freezer compartment"
}
''';
    }
  }

  /// Parse JSON response from Gemini API
  Map<String, String> _parseItemDetailResponse(
    String response,
    bool isThaiLanguage,
  ) {
    try {
      // Parse JSON response directly
      final jsonResponse = jsonDecode(response) as Map<String, dynamic>;

      return {
        'category': jsonResponse['category']?.toString() ?? 'Unknown',
        'duration': jsonResponse['duration']?.toString() ?? 'Not specified',
        'tips': jsonResponse['tips']?.toString() ?? 'Store properly',
      };
    } catch (e) {
      // Fallback if JSON parsing fails
      return _generateFallbackItemDetails('', isThaiLanguage);
    }
  }

  /// Generate fallback item details with better Thai phrases
  Map<String, String> _generateFallbackItemDetails(
    String itemName,
    bool isThaiLanguage,
  ) {
    return isThaiLanguage
        ? {
            'category': 'อาหารทั่วไป',
            'duration': '3-7 วัน',
            'tips': 'เก็บในตู้เย็น',
          }
        : {
            'category': 'General Food',
            'duration': '3-7 days',
            'tips': 'Store in refrigerator',
          };
  }

  @override
  Future<Map<String, String>> identifyItemFromLabel(String ocrText) async {
    final isThaiLanguage = _isThaiText(ocrText);

    try {
      final provider = await providerService.getProvider();

      if (provider == AiProvider.openai) {
        final response = await openaiClient.dio.post(
          '/chat/completions',
          data: {
            'model': 'gpt-4o-mini',
            'temperature': 0.2,
            'max_tokens': 300,
            'response_format': {'type': 'json_object'},
            'messages': [
              {
                'role': 'system',
                'content': isThaiLanguage
                    ? 'คุณเป็นผู้ช่วยระบุสินค้าในแอป Smart Pantry จากข้อความบนฉลากสินค้า'
                    : 'You identify grocery items from OCR label text for the Smart Pantry app.',
              },
              {
                'role': 'user',
                'content': _buildIdentifyFromLabelPrompt(ocrText, isThaiLanguage),
              },
            ],
          },
        );

        final result = _extractOpenAiText(response.data);
        if (result.isEmpty) {
          return _fallbackIdentifyFromLabel(isThaiLanguage);
        }

        return _parseIdentifyFromLabelResponse(result, isThaiLanguage);
      }

      final response = await geminiClient.dio.post(
        '/models/gemini-2.5-flash:generateContent',
        data: {
          'contents': [
            {
              'parts': [
                {
                  'text': _buildIdentifyFromLabelPrompt(
                    ocrText,
                    isThaiLanguage,
                  ),
                },
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.2,
            'maxOutputTokens': 300,
            'responseMimeType': 'application/json',
          },
        },
      );

      final result = _extractGeminiResponse(response.data);
      if (result.isEmpty) {
        return _fallbackIdentifyFromLabel(isThaiLanguage);
      }

      return _parseIdentifyFromLabelResponse(result, isThaiLanguage);
    } on DioException {
      return _fallbackIdentifyFromLabel(isThaiLanguage);
    } catch (_) {
      return _fallbackIdentifyFromLabel(isThaiLanguage);
    }
  }

  String _buildIdentifyFromLabelPrompt(String ocrText, bool isThaiLanguage) {
    if (isThaiLanguage) {
      return '''
คุณเป็นผู้ช่วยระบุสินค้าในแอป Smart Pantry จากข้อความ OCR ที่อ่านได้จากฉลากสินค้า

ข้อความ OCR:
"""
$ocrText
"""

ให้ตอบกลับเป็น JSON เท่านั้น ไม่มีข้อความอื่น โดยมี key ดังนี้:

name: ชื่อสินค้าที่เหมาะสม (ภาษาเดียวกับข้อความ)
category: เลือก 1 จากรายการนี้เท่านั้น: Food, Drink, Household, Snack
unit: เลือก 1 จากรายการนี้เท่านั้น: pcs, bottle, pack, kg
quantity: จำนวนที่เดาได้เป็นเลขจำนวนเต็ม (ถ้าไม่มั่นใจให้ใส่ "")
confidence: ความมั่นใจเป็นตัวเลข 0-100

ตัวอย่าง:
{
  "name": "นมสด",
  "category": "Drink",
  "unit": "bottle",
  "quantity": "1",
  "confidence": 78
}
''';
    }

    return '''
You help identify a grocery item for the Smart Pantry app from OCR text extracted from a product label.

OCR text:
"""
$ocrText
"""

Respond ONLY as JSON, no other text. Use these keys:

name: best item name (same language as OCR)
category: choose exactly one of: Food, Drink, Household, Snack
unit: choose exactly one of: pcs, bottle, pack, kg
quantity: integer as a string (if unsure, use "")
confidence: number 0-100

Example:
{
  "name": "Milk",
  "category": "Drink",
  "unit": "bottle",
  "quantity": "1",
  "confidence": 78
}
''';
  }

  Map<String, String> _parseIdentifyFromLabelResponse(
    String response,
    bool isThaiLanguage,
  ) {
    try {
      final jsonResponse = jsonDecode(response) as Map<String, dynamic>;
      return {
        'name': jsonResponse['name']?.toString() ?? '',
        'category': jsonResponse['category']?.toString() ?? '',
        'unit': jsonResponse['unit']?.toString() ?? '',
        'quantity': jsonResponse['quantity']?.toString() ?? '',
        'confidence': jsonResponse['confidence']?.toString() ?? '',
      };
    } catch (_) {
      return _fallbackIdentifyFromLabel(isThaiLanguage);
    }
  }

  Map<String, String> _fallbackIdentifyFromLabel(bool isThaiLanguage) {
    return {
      'name': '',
      'category': 'Food',
      'unit': 'pcs',
      'quantity': '',
      'confidence': '0',
    };
  }
}
