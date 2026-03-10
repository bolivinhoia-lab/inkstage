import Foundation
import CoreML
import Vision
import PencilKit

class ShapeRecognitionManager {
    static let shared = ShapeRecognitionManager()
    
    // Converte PKDrawing (traço livre) em formas geométricas perfeitas
    func processDrawing(_ drawing: PKDrawing, in rect: CGRect) -> PKDrawing {
        var newStrokes = [PKStroke]()
        
        for stroke in drawing.strokes {
            if let recognizedShape = recognizeShape(from: stroke) {
                newStrokes.append(recognizedShape)
            } else {
                newStrokes.append(stroke)
            }
        }
        
        return PKDrawing(strokes: newStrokes)
    }
    
    private func recognizeShape(from stroke: PKStroke) -> PKStroke? {
        let points = stroke.path.map { $0.location }
        guard points.count > 10 else { return nil }
        
        let bounds = stroke.renderBounds
        
        // Detecção de "Intenção de Círculo" baseada em bounding box squareness
        let isCircular = abs(bounds.width - bounds.height) < (bounds.width * 0.2)
        
        if isCircular {
            return createPerfectEllipse(in: bounds, originalStroke: stroke)
        }
        
        return nil
    }
    
    private func createPerfectEllipse(in rect: CGRect, originalStroke: PKStroke) -> PKStroke {
        // Gera um novo PKStroke que representa uma elipse perfeita
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radiusX = rect.width / 2
        let radiusY = rect.height / 2
        
        var points = [PKStrokePoint]()
        for i in 0...100 {
            let angle = CGFloat(i) * .pi * 2 / 100
            let x = center.x + cos(angle) * radiusX
            let y = center.y + sin(angle) * radiusY
            
            let point = PKStrokePoint(
                location: CGPoint(x: x, y: y),
                timeOffset: 0,
                size: CGSize(width: 4, height: 4), // Placeholder fixo
                opacity: 1,
                force: 1,
                azimuth: 0,
                altitude: .pi / 2
            )
            points.append(point)
        }
        
        let path = PKStrokePath(controlPoints: points, creationDate: Date())
        return PKStroke(ink: originalStroke.ink, path: path)
    }
}
