import Foundation
import Capacitor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(GesturePlugin)
public class GesturePlugin: CAPPlugin {
    private let implementation = Gesture()
    
    func disableSubviewGestures(view: UIView) {
        view.gestureRecognizers?.forEach {gesture in
            guard let longTapGesture = gesture as? UILongPressGestureRecognizer else {
                return
            }
            
            print(longTapGesture)
            
            longTapGesture.isEnabled = false
        }
        
        view.subviews.forEach {self.disableSubviewGestures(view: $0)}
    }
    
    public override func load() {
        print("## gesture plugin loaded")
        
        
        print(self.webView?.gestureRecognizers)

        self.webView?.addGestureRecognizer(
            BaseGesture()
                .onTouchBegan {data in
                    self.callTouchCallback(type: "down", data: data);
                }
                .onTouchMove {data in
                    self.callTouchCallback(type: "move", data: data)
                }
                .onTouchEnd {data in
                    self.callTouchCallback(type: "up", data: data)
                }
                .onTouchCancelled {data in
                    self.callTouchCallback(type: "cancel", data: data)
                }
        )
    }
    
    @objc func echo(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        call.resolve([
            "value": implementation.echo(value)
        ])
    }
    
    func callTouchCallback(type: String, data: [JSTouchData]) {
        var dataString = "var data = ["
        
        for value in data {
            dataString += "{x: \(value.x), y: \(value.y), id: \(value.id)},"
        }
        
        dataString += "];"
        
        self.bridge?.eval(js: """
            \(dataString)
        
            if (window.nativeTouchCallback) {
               for (let value of data) {
                 window.nativeTouchCallback('\(type)', value.id, value.x, value.y);
               }
            }
        """)
    }
    
}

typealias TouchCallback = (_ data: [JSTouchData]) -> Void

struct JSTouchData {
    let id: Int;
    let x: CGFloat;
    let y: CGFloat;
}

class BaseGesture: UIGestureRecognizer {
    private var onTouchBegan: TouchCallback?;
    private var onTouchMove: TouchCallback?;
    private var onTouchEnd: TouchCallback?;
    private var onTouchCancelled: TouchCallback?;
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        self.onTouchBegan?(self.convertTouchsToJSData(touches: touches))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        let coalTouches = event.coalescedTouches(for: touches.first!) ?? []
        
        if coalTouches.count > 0 {
            for touch in coalTouches {
                self.onTouchMove?(self.convertTouchsToJSData(touches: Set([touch])))
            }
        } else {
            self.onTouchMove?(self.convertTouchsToJSData(touches: touches))
        }
    }
        
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        self.onTouchEnd?(self.convertTouchsToJSData(touches: touches))
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        self.onTouchCancelled?(self.convertTouchsToJSData(touches: touches))
    }
    
    func onTouchBegan(callback: @escaping TouchCallback) -> BaseGesture {
        self.onTouchBegan = callback
        
        return self
    }
    
    func onTouchMove(callback: @escaping TouchCallback) -> BaseGesture {
        self.onTouchMove = callback
        
        return self
    }
    
    func onTouchEnd(callback: @escaping TouchCallback) -> BaseGesture {
        self.onTouchEnd = callback
        
        return self
    }
    
    func onTouchCancelled(callback: @escaping TouchCallback) -> BaseGesture {
        self.onTouchCancelled = callback
        
        return self
    }
    
    func convertTouchsToJSData(touches: Set<UITouch>) -> [JSTouchData] {
        return touches.map {touch -> JSTouchData in
            let location = touch.preciseLocation(in: nil)
            
            
            return JSTouchData(id: touch.estimationUpdateIndex?.intValue ?? 0, x: location.x, y: location.y)
        }
    }
}
