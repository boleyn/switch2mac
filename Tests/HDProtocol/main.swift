import Foundation
func packet(_ v:[Float]) -> Data {
    var d=Data([0x53,0x32,0x48,0x31])
    for f in v { var b=f.bitPattern.littleEndian; withUnsafeBytes(of:&b){ d.append(contentsOf:$0) } }
    return d
}
let data=packet([0.25,160,0.5,320,0.75,80,1,400])
let hd=Switch2.HDRumble.decode(data)!
precondition(hd.left.lfFreq==160 && hd.left.hfFreq==320 && hd.left.lfAmp==255 && hd.left.hfAmp==511)
precondition(hd.right.lfFreq==80 && hd.right.hfFreq==400 && hd.right.lfAmp==767 && hd.right.hfAmp==1023)
let motor=Switch2.motorPacket(left:hd.left,right:hd.right,packetID:7,model:.proController2)
precondition(motor.count==33 && motor[1]==0x57 && motor[17]==0x57)
precondition(motor.subdata(in:2..<7)==motor.subdata(in:7..<12))
precondition(motor.subdata(in:2..<7) != motor.subdata(in:18..<23))
precondition(Switch2.HDRumble.decode(data.dropLast())==nil)
precondition(Switch2.HDRumble.decode(packet([.nan,160,0,320,0,160,0,320]))==nil)
precondition(!Switch2.HDRumble.decode(packet([0,160,0,320,0,160,0,320]))!.active)
print("PASS: S2H1 independent handles/bands/Hz, three continuous subframes, malformed rejection, explicit silence")
