//
//  GeminiManager.swift
//  FitFlow
//
//  Created by Engin Bolat on 22.12.2025.
//

import Foundation
import GoogleGenerativeAI

protocol GeminiServiceProtocol {
    func fetchWorkoutPlan(prompt: String) async throws -> AIWorkoutResponse
    func generateWorkoutAndMealPlan(profile: UserProfile) -> String
}

enum GeminiError: Error {
    case invalidResponse
    case decodingError
    case missingAPIKey
}

final class GeminiService: GeminiServiceProtocol {
    private let apiKey: String
    private lazy var model = GenerativeModel(name: "gemini-flash-latest", apiKey: apiKey)
    
    init(apiKey: String = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String ?? "") {
        self.apiKey = apiKey
    }
    
    func fetchWorkoutPlan(prompt: String) async throws -> AIWorkoutResponse {
        guard !apiKey.isEmpty else { throw GeminiError.missingAPIKey }
        
        let response = try await model.generateContent(prompt)
        
        guard
            let text = response.text,
            let cleanedJSON = extractJSONPayload(from: text),
            let data = cleanedJSON.data(using: .utf8)
        else {
            throw GeminiError.invalidResponse
        }
        
        do {
            _ = try JSONSerialization.jsonObject(with: data)
            let decodedResponse = try JSONDecoder().decode(AIWorkoutResponse.self, from: data)
            return decodedResponse
        } catch {
            print("Decoding Hatası: \(error)")
            throw GeminiError.decodingError
        }
    }
    
    func generateWorkoutAndMealPlan(profile: UserProfile) -> String {
        return """
                Sen profesyonel bir fitness ve beslenme koçusun. Kullanıcının onboarding formunda girdiği verilere göre 1 haftalık kişiselleştirilmiş bir program hazırla.
                
                KULLANICI PROFİLİ:
                - İsim: \(profile.name)
                - Hedef: \(profile.goal)
                - Boy: \(profile.height ?? 175.0) cm
                - Kilo: \(profile.weight ?? 80.0) kg
                - Yaş: \(profile.age ?? 18)
                
                SABİT BESLENME HEDEFLERİ:
                - Günlük Kalori: \(profile.macros.calories) kcal
                - Protein: \(profile.macros.protein)g
                - Yağ: \(profile.macros.fat)g
                - Karbonhidrat: \(profile.macros.carbs)g
                
                İSTEK:
                1. Kullanıcının "\(profile.goal)" hedefine uygun, boy ve kilo oranını dikkate alan bir idman programı yaz.
                2. Her egzersiz için YouTube'dan uygun bir eğitim videosu bul ve video_url olarak ekle. Video URL formatı: https://www.youtube.com/watch?v=VIDEO_ID veya https://youtu.be/VIDEO_ID şeklinde olmalı. Eğer uygun video bulamazsan null kullan.
                3. 'meal_plan' kısmında, kullanıcının makrolarına sadık kalarak HAFTALIK günlük yemek önerileri ver. Her gün için (Pazartesi'den Pazar'a) ayrı ayrı yemek planı hazırla. Her gün için:
                   - day: "Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi", "Pazar"
                   - meals: O güne özel öğünler (Kahvaltı, Öğle Yemeği, Akşam Yemeği, Ara Öğün)
                   Her yemek için:
                   - meal_type: "Kahvaltı", "Öğle Yemeği", "Akşam Yemeği" veya "Ara Öğün"
                   - name: Yemek adı
                   - description: Yemek açıklaması ve hazırlanışı
                   - calories, protein, carbs, fat: Makro değerleri (günlük toplam makrolara uygun olmalı)
                   - video_url: Eğer yemeğin hazırlanışı için YouTube'da video varsa ekle, yoksa null
                4. 'nutrition_advice' kısmında, kullanıcının makrolarına sadık kalarak beslenme stratejisi ve ipuçları ver.
                
                ÖNEMLİ:
                - Tüm video URL'leri geçerli YouTube URL'leri olmalı
                - Video URL'leri opsiyonel (null olabilir)
                - Yemek önerileri kullanıcının günlük makro hedeflerine uygun olmalı
                - Egzersiz videoları Türkçe veya İngilizce olabilir
                
                Yanıtını SADECE aşağıdaki JSON formatında ver:
                {
                  "weekly_focus": "Haftalık ana odak",
                  "nutrition_advice": "Makrolara uygun beslenme stratejisi ve ipuçları",
                  "meal_plan": {
                    "daily_meal_plans": [
                      {
                        "day": "Pazartesi",
                        "meals": [
                          {
                            "meal_type": "Kahvaltı",
                            "name": "Yemek Adı",
                            "description": "Yemek açıklaması ve hazırlanışı",
                            "calories": 500,
                            "protein": 30.0,
                            "carbs": 50.0,
                            "fat": 20.0,
                            "video_url": "https://www.youtube.com/watch?v=VIDEO_ID veya null"
                          },
                          {
                            "meal_type": "Öğle Yemeği",
                            "name": "Yemek Adı",
                            "description": "Yemek açıklaması ve hazırlanışı",
                            "calories": 600,
                            "protein": 40.0,
                            "carbs": 60.0,
                            "fat": 25.0,
                            "video_url": "https://www.youtube.com/watch?v=VIDEO_ID veya null"
                          }
                        ]
                      }
                    ]
                  },
                  "daily_plan": [
                    {
                      "day": "Pazartesi",
                      "title": "Günün Başlığı",
                      "exercises": [
                        {
                          "name": "Egzersiz Adı",
                          "sets": "Set",
                          "reps": "Tekrar",
                          "video_url": "https://www.youtube.com/watch?v=VIDEO_ID veya null"
                        }
                      ]
                    }
                  ]
                }
                """
    }
    
    /// Removes Markdown fences and extracts the first JSON object from the model response.
    private func extractJSONPayload(from text: String) -> String? {
        let unfenced = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let range = unfenced.range(of: "\\{[\\s\\S]*\\}", options: .regularExpression) {
            return String(unfenced[range])
        }
        
        return unfenced.isEmpty ? nil : unfenced
    }
}
