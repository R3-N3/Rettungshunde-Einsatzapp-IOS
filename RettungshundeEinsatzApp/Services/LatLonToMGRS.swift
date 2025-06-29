//
//  Untitled.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 29.06.25.
//

import Foundation
import CoreLocation

import Foundation
import CoreLocation

func latLonToMGRS(latitude lat: Double, longitude long: Double) -> String {
    if lat < -80 { return "Too far South" }
    if lat > 84 { return "Too far North" }

    let c = 1 + floor((long + 180) / 6)
    let e = c * 6 - 183
    let k = lat * Double.pi / 180
    let l = long * Double.pi / 180
    let m = e * Double.pi / 180
    let n = cos(k)
    let o = 0.006739496819936062 * pow(n, 2.0)
    let p = 40680631590769 / (6356752.314 * sqrt(1 + o))
    let q = tan(k)
    let r = q * q
    let t = l - m
    let u = 1.0 - r + o
    let v = 5.0 - r + 9 * o + 4.0 * pow(o,2.0)
    let w = 5.0 - 18.0 * r + pow(r,2.0) + 14.0 * o - 58.0 * r * o
    let x = 61.0 - 58.0 * r + pow(r,2.0) + 270.0 * o - 330.0 * r * o
    let y = 61.0 - 479.0 * r + 179.0 * pow(r,2.0) - pow(r,3.0)
    let z = 1385.0 - 3111.0 * r + 543.0 * pow(r,2.0) - pow(r,3.0)

    var aa = p * n * t +
        (p / 6.0 * pow(n,3.0) * u * pow(t,3.0)) +
        (p / 120.0 * pow(n,5.0) * w * pow(t,5.0)) +
        (p / 5040.0 * pow(n,7.0) * y * pow(t,7.0))

    var ab = 6367449.14570093 * (k - (0.00251882794504 * sin(2 * k)) +
        (0.00000264354112 * sin(4 * k)) -
        (0.00000000345262 * sin(6 * k)) +
        (0.000000000004892 * sin(8 * k))) +
        (q / 2.0 * p * pow(n,2.0) * pow(t,2.0)) +
        (q / 24.0 * p * pow(n,4.0) * v * pow(t,4.0)) +
        (q / 720.0 * p * pow(n,6.0) * x * pow(t,6.0)) +
        (q / 40320.0 * p * pow(n,8.0) * z * pow(t,8.0))

    aa = aa * 0.9996 + 500000.0
    ab *= 0.9996
    if ab < 0.0 { ab += 10000000.0 }

    let latBands = "CDEFGHJKLMNPQRSTUVWXX"
    let adIndex = Int(floor(lat / 8 + 10))
    let ad = latBands[latBands.index(latBands.startIndex, offsetBy: adIndex)]

    let ae = Int(floor(aa / 100000))
    let eastingSets = ["ABCDEFGH", "JKLMNPQR", "STUVWXYZ"]
    let eastingSetIndex = (Int(c) - 1) % 3
    let af = eastingSets[eastingSetIndex][eastingSets[eastingSetIndex].index(eastingSets[eastingSetIndex].startIndex, offsetBy: ae - 1)]

    let ag = Int(floor(ab / 100000)) % 20
    let northingSets = ["ABCDEFGHJKLMNPQRSTUV", "FGHJKLMNPQRSTUVABCDE"]
    let northingSetIndex = (Int(c) - 1) % 2
    let ah = northingSets[northingSetIndex][northingSets[northingSetIndex].index(northingSets[northingSetIndex].startIndex, offsetBy: ag)]

    func pad(_ value: Int) -> String {
        if value < 10 { return "0000\(value)" }
        if value < 100 { return "000\(value)" }
        if value < 1000 { return "00\(value)" }
        if value < 10000 { return "0\(value)" }
        return "\(value)"
    }

    aa = floor(aa.truncatingRemainder(dividingBy: 100000))
    ab = floor(ab.truncatingRemainder(dividingBy: 100000))

    return "\(Int(c))\(ad) \(af)\(ah) \(pad(Int(aa))) \(pad(Int(ab)))"
}
