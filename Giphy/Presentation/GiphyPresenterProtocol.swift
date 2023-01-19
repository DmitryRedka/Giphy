import UIKit

// Протокол для общения между View и Presetner слоями
protocol GiphyPresenterProtocol: AnyObject {
    // Конструктор слоя Presetner
    init(giphyFactory: GiphyFactoryProtocol)

    // Метод получения случайной гифки
    func fetchNextGiphy()

    // Сохранение гифки в файлы
    func saveGif(_ image: UIImage?)
    
    func proceedToNextGif()
    
    func createAlert(alertModel: AlertModel) -> UIAlertController 
    
}
