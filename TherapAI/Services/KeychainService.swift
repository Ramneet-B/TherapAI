import Foundation
import Security

class KeychainService {
    static let shared = KeychainService()
    
    private init() {}
    
    private let service = "com.therapai.app"
    
    enum KeychainKey: String {
        case authToken = "auth_token"
        case userEmail = "user_email"
        case userID = "user_id"
        case userData = "user_data"
    }
    
    // MARK: - Generic Keychain Operations
    
    func save<T: Codable>(_ value: T, for key: KeychainKey) -> Bool {
        do {
            let data = try JSONEncoder().encode(value)
            return save(data: data, for: key)
        } catch {
            return false
        }
    }
    
    func load<T: Codable>(_ type: T.Type, for key: KeychainKey) -> T? {
        guard let data = load(for: key) else { return nil }
        
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            return nil
        }
    }
    
    func save(string: String, for key: KeychainKey) -> Bool {
        guard let data = string.data(using: .utf8) else { return false }
        return save(data: data, for: key)
    }
    
    func loadString(for key: KeychainKey) -> String? {
        guard let data = load(for: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    private func save(data: Data, for key: KeychainKey) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data
        ]
        
        // Delete existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    private func load(for key: KeychainKey) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess {
            return result as? Data
        }
        return nil
    }
    
    func delete(for key: KeychainKey) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
    
    func clearAll() {
        for key in [KeychainKey.authToken, .userEmail, .userID, .userData] {
            delete(for: key)
        }
    }
}