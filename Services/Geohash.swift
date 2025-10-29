// MARK: - Geohash Helper

struct Geohash {
    private static let base32 = Array("0123456789bcdefghjkmnpqrstuvwxyz")
    
    static func encode(latitude: Double, longitude: Double, precision: Int = 7) -> String {
        var latRange = (-90.0, 90.0)
        var lonRange = (-180.0, 180.0)
        var geohash = ""
        var bits = 0
        var bit = 0
        var isEven = true
        
        while geohash.count < precision {
            if isEven {
                let mid = (lonRange.0 + lonRange.1) / 2
                if longitude > mid {
                    bit |= (1 << (4 - bits))
                    lonRange.0 = mid
                } else {
                    lonRange.1 = mid
                }
            } else {
                let mid = (latRange.0 + latRange.1) / 2
                if latitude > mid {
                    bit |= (1 << (4 - bits))
                    latRange.0 = mid
                } else {
                    latRange.1 = mid
                }
            }
            
            isEven = !isEven
            bits += 1
            
            if bits == 5 {
                geohash.append(base32[bit])
                bits = 0
                bit = 0
            }
        }
        
        return geohash
    }
    
    static func neighbors(geohash: String) -> [String] {
        let neighbors = [
            "n", "ne", "e", "se", "s", "sw", "w", "nw"
        ]
        
        // Simplified: return geohash prefixes for neighboring cells
        var result: [String] = []
        for neighbor in neighbors {
            result.append(geohash) // Placeholder - proper implementation needed
        }
        return result
    }
}
