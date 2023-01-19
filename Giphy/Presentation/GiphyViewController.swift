import UIKit

final class GiphyViewController: UIViewController {

    private let amountGif = 10
    private var showGifCounter = 1
    private var counterLikedGif = 0
    private var likedGifCounter: Int = 0
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var giphyImageView: UIImageView!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var giphyActivityIndicatorView: UIActivityIndicatorView!

    
    @IBAction func onYesButtonTapped() {
        
        counterLikedGif += 1
        presenter.saveGif(giphyImageView.image)
        highlitImageBorder(isLikedGif: true)
        proceedToNextOrEndGif()
    }

    // Нажатие на кнопку дизлайка
    @IBAction func onNoButtonTapped() {
        
        highlitImageBorder(isLikedGif: false)
        proceedToNextOrEndGif()
    }

    private lazy var presenter: GiphyPresenterProtocol = {
        
        let presenter = GiphyPresenter()
        presenter.viewController = self
        return presenter
    }()

    // MARK: - Жизенный цикл экрана

    override func viewDidLoad() {
        
        super.viewDidLoad()
        restart()
    }
    
    func highlitImageBorder (isLikedGif: Bool) {

        giphyImageView.layer.masksToBounds = true
        giphyImageView.layer.borderWidth = 8
        if isLikedGif {
            giphyImageView.layer.borderColor = UIColor.ypGreen?.cgColor
        } else {
            giphyImageView.layer.borderColor = UIColor.ypRed?.cgColor
        }
    }
    
    func buttonsEnable(isEnabled: Bool) {
        
        likeButton.isEnabled = isEnabled
        dislikeButton.isEnabled = isEnabled
    }

}

// MARK: - Приватные методы

private extension GiphyViewController {

    func restart() {
        
        hideBoarder()
        presenter.fetchNextGiphy()
        showGifCounter = 1
        counterLikedGif = 0
        indexLabel.text = "\(showGifCounter)/\(amountGif)"
    }
}

// MARK: - GiphyViewControllerProtocol

extension GiphyViewController: GiphyViewControllerProtocol {
    
    func showError() {
        let alertError = AlertModel(title: "Что-то пошло не так(",
                                         message: "Невозможно загрузить данные",
                                         buttonText: "Попробовать еще раз",
                                         completion: {[weak self] _ in
            guard let self = self  else { return }
            self.restart()
        })
        didPresentAlert(alertModel: alertError)
    }

    func showEndOfGiphy() {
        let alertEndOfGiphy = AlertModel(title: "Мемы закончились!",
                                         message: "Вам понравилось: \(counterLikedGif)/\(amountGif)",
                                         buttonText: "Хочу посмотреть еще гифок",
                                         completion: {[weak self] _ in
            guard let self = self  else { return }
            self.restart()
        })
        didPresentAlert(alertModel: alertEndOfGiphy)
    }

    func showGiphy(_ image: UIImage?) {
        
        giphyImageView.image = image
    }

    func showLoader() {
        
        giphyImageView.image = nil
        giphyActivityIndicatorView.startAnimating()
    }

    func hideHoaler() {
        
        giphyActivityIndicatorView.stopAnimating()
    }
    
    func hideBoarder() {
        
        giphyImageView.layer.borderWidth = 0
    }
    
    func proceedToNextOrEndGif() {
        
        if showGifCounter == amountGif {
            showEndOfGiphy()
        } else {
            
            showGifCounter += 1
            indexLabel.text = "\(showGifCounter)/\(amountGif)"
            presenter.proceedToNextGif()

        }
    }
    
    func didPresentAlert(alertModel: AlertModel) {
        let alert = presenter.createAlert(alertModel: alertModel)
        present(alert, animated: true, completion: nil)
    }
}


