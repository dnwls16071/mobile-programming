//
//  ViewController.swift
//  15장
//
//  Created by 203a21 on 2022/05/27.
//

import UIKit
import MobileCoreServices   // 다양한 타입들을 사용하기 위해서 헤더 파일을 추가합니다.
class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {   // 델리게이트 프로토콜 두 개를 추가합니다.

    
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    var captureImage: UIImage!  // 사진을 저장할 변수
    var videoURL: URL!  // 녹화한 비디오의 URL을 저장할 변수
    var flagImageSave = false   // 사진 저장 여부를 나타낼 변수
    @IBOutlet var imgView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // 사진 촬영하기 기능을 담당하는 코드
    @IBAction func btnCaptureImageFromCamera(_ sender: UIButton) {
        if (UIImagePickerController.isSourceTypeAvailable(.camera)) {   // 카메라를 사용할 수 있는 환경이라면?
            flagImageSave = true
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.mediaTypes = ["public.image"]
            imagePicker.allowsEditing = false   // 편집을 허용하지 않는다.
            
            present(imagePicker, animated: true, completion: nil)
        }
        else    {   // 카메라를 사용할 수 없는 환경이라면?
            myAlert("Camera is inaccessable", message: "Application cannot access the camera.") // 얼럿 기능을 이용해서 경고문을 출력한다.
        }
    }
    
    // 사진 불러오기 기능을 담당하는 코드
    @IBAction func btnLoadImageFromLibrary(_ sender: UIButton) {
        if (UIImagePickerController.isSourceTypeAvailable(.photoLibrary))   {   // 사진 불러오기 기능을 사용할 수 있는 환경이라면?
            flagImageSave = false
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = ["public.image"]
            imagePicker.allowsEditing = true
            
            present(imagePicker, animated: true, completion: nil)
        }
        else    {   // 사진 불러오기 기능을 사용할 수 없는 환경이라면?
            myAlert("Photo album inaccessible", message: "Application cannot access the photo album")   // 얼럿 기능을 이용해서 경고문을 출력한다.
        }
    }
    
    // 비디오 촬영하기 기능을 담당하는 코드
    @IBAction func btnRecordVideoFromCamera(_ sender: UIButton) {   // 비디오 촬영을 사용할 수 있는 환경이라면?
        if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
            flagImageSave = true
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.mediaTypes = ["public.movie"]
            imagePicker.allowsEditing = false
            
            present(imagePicker, animated: true, completion: nil)
        }
        else    {   // 비디오 촬영을 사용할 수 없는 환경이라면?
            myAlert("Camera inaccessible", message: "Application cannot access the camera.")    // 얼럿 기능을 이용해서 경고문을 출력한다.
        }
    }
    
    // 비디오 불러오기 기능을 담당하는 코드
    @IBAction func btnLoadVideoFromLibrary(_ sender: UIButton) {    // 비디오 불러오기를 사용할 수 있는 환경이라면?
        if (UIImagePickerController.isSourceTypeAvailable(.photoLibrary))   {
            flagImageSave = false
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = ["public.movie"]
            imagePicker.allowsEditing = false
            
            present(imagePicker, animated: true, completion: nil)
        }
        else    {   // 비디오 불러오기 기능을 사용할 수 없는 환경이라면?
            myAlert("Photo album inaccessable", message: "Application cannot access the photo album.")  // 얼럿 기능을 이용해서 경고문을 출력한다.
        }
    }
    
    // 사진, 비디오 촬영이나 선택이 끝났을 때 호출되는 델리게이트 메서드
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 미디어 종류를 확인한다.
        let mediaType = info[UIImagePickerController.InfoKey.mediaType]
        as! NSString
        // 만약 미디어 종류가 사진이라면?
        if mediaType.isEqual(to: "public.image" as String)  {
            // 사진을 가져온다.
            captureImage = info[UIImagePickerController.InfoKey.originalImage]
            as? UIImage
            
            if flagImageSave    {   // flagImageSave의 Bool값이 true일때
                //  사진을 포토라이브러리에 저장한다.
                UIImageWriteToSavedPhotosAlbum(captureImage, self, nil, nil)
            }
            
            // 가져온 사진을 이미지 뷰에 출력
            imgView.image = captureImage
        }   // 만약 미디어 종류가 비디오라면?
        else if mediaType.isEqual(to: "public.movie" as String) {
            //flagImageSave의 값이 true일 때
            if flagImageSave    {
                videoURL = (info[UIImagePickerController.InfoKey.mediaURL]
                as! URL)
                // 비디오를 포토라이브러리에 저장한다.
                UISaveVideoAtPathToSavedPhotosAlbum(videoURL.relativePath, self, nil, nil)
            }
        }
        
        // 현재의 뷰 제거(이미지 피커를 제거한다.)
        self.dismiss(animated: true, completion: nil)
    }
    // 사진, 비디오 촬영이나 선택을 취소했을 때 호출되는 델리게이트 메서드
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // 현재의 뷰 제거(이미지 피커를 제거한다.)
        self.dismiss(animated: true, completion: nil)
    }
    
    // 경고 창을 출력하는 함수입니다.
    func myAlert(_ title: String, message: String)  {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}

