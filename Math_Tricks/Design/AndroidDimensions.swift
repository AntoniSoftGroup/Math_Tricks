import UIKit

/// Android's smallest-width/orientation qualifiers precede density qualifiers.
/// iOS points correspond to dp; displayScale selects the matching density bucket.
enum AndroidDimensions {
    private struct ResourceSet: Decodable {
        let qualifier: String
        let smallestWidth: Int
        let landscape: Bool
        let density: Double
        let values: [String: Double]
    }
    private static let sets: [ResourceSet] = {
        guard let url=Bundle.main.url(forResource:"AndroidDimensions",withExtension:"json"),
              let bytes=try? Data(contentsOf:url),let values=try? JSONDecoder().decode([ResourceSet].self,from:bytes) else {
            preconditionFailure("Bundled Android dimensions are missing")
        }
        return values
    }()
    static func value(_ name:String,traits:UITraitCollection,size:CGSize?=nil,fallback:CGFloat)->CGFloat {
        let bounds=size ?? UIScreen.main.bounds.size
        let screenSmallest=min(UIScreen.main.bounds.width,UIScreen.main.bounds.height)
        let smallest=size.map{min($0.width,$0.height)} ?? (traits.horizontalSizeClass == .compact ? min(599,screenSmallest) : screenSmallest)
        let landscape=bounds.width>bounds.height
        let scale=Double(traits.displayScale>0 ? traits.displayScale : UIScreen.main.scale)
        let matches=sets.filter{$0.values[name] != nil && CGFloat($0.smallestWidth)<=smallest && (!$0.landscape || landscape)}
        let best=matches.sorted {
            if $0.smallestWidth != $1.smallestWidth{return $0.smallestWidth>$1.smallestWidth}
            if $0.landscape != $1.landscape{return $0.landscape}
            let a=abs(log($0.density/scale)),b=abs(log($1.density/scale))
            if a != b{return a<b}
            if $0.density != $1.density{return $0.density>$1.density}
            return $0.qualifier.count>$1.qualifier.count
        }.first
        return best?.values[name].map{CGFloat($0)} ?? fallback
    }
}
