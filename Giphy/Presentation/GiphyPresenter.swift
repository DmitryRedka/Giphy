import UIKit
import Photos

// Presetner (бизнес слой для получения слудеющей гифки)
final class GiphyPresenter: GiphyPresenterProtocol {
    private var giphyFactory: GiphyFactoryProtocol

    // Слой View для общения и отображения случайной гифки
    weak var viewController: GiphyViewControllerProtocol?

    // MARK: - GiphyPresenterProtocol

    init(giphyFactory: GiphyFactoryProtocol = GiphyFactory()) {
        self.giphyFactory = giphyFactory
        self.giphyFactory.delegate = self
    }

    func fetchNextGiphy() {
        viewController?.showLoader()
        giphyFactory.requestNextGiphy()
    }

    // Сохранение гифки
    func saveGif(_ image: UIImage?) {
        guard let data = image?.pngData() else {
            return
        }

        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .photo, data: data, options: nil)
        })
    }
    
    func proceedToNextGif() {
        viewController?.buttonsEnable(isEnabled: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { [weak self] in
            guard let self = self else {
                return
            }
            self.viewController?.hideBoarder()
            self.fetchNextGiphy()
            self.viewController?.buttonsEnable(isEnabled: true)
        })
    }
    func createAlert(alertModel: AlertModel) -> UIAlertController {
        
        let alert = UIAlertController(title: alertModel.title,
                                      message: alertModel.message,
                                      preferredStyle: .alert)
        alert.view.accessibilityIdentifier = "ResultAlert"
        let action = UIAlertAction(title: alertModel.buttonText, style: .default, handler: alertModel.completion)
        alert.addAction(action)
        return alert
    }
}

// MARK: - GiphyFactoryDelegate

extension GiphyPresenter: GiphyFactoryDelegate {
    // Успешная загрузка гифки
    func didRecieveNextGiphy(_ giphy: GiphyModel) {
        // Преобразуем набор картинок в гифку
        let image = UIImage.gif(url: giphy.url)

        DispatchQueue.main.async { [weak self] in
            
            self?.viewController?.hideHoaler()
            self?.viewController?.showGiphy(image)
        }
    }

    // При загрузке гифки произошла ошибка
    func didReciveError(_ error: GiphyError) {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.hideHoaler()
            self?.viewController?.showError()
        }
    }
}
