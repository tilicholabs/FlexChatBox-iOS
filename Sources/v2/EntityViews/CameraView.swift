import Foundation
import SwiftUI

// MARK: - CameraView
public struct CameraView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewModel = ViewModel()
    public var cameraSuccessCallback: CameraSuccessCallback
    
    public var body: some View {
        Button {
            viewModel.checkCameraAuthorizationStatus()
        } label: {
            Image(systemName: FlexHelper.cameraButtonImageName)
                .flexIconFrame()
                .padding()
                .foregroundColor(Color.white)
                .flexBackground(hex: hexColor(status: viewModel.cameraStatus != .denied))
                .flexIconCornerRadius()
        }
        .onAppear {
            viewModel.checkCameraStatusWhenAppear()
        }
        .sheet(isPresented: $viewModel.presentCamera) {
            CaptureImage(capturedImage: $viewModel.capturedImage, videoURL: $viewModel.videoURL)
                .ignoresSafeArea()
                .onReceive(viewModel.$capturedImage) { image in
                    guard let image else { return }
                    cameraSuccessCallback(image, nil)
                }
                .onReceive(viewModel.$videoURL) { url in
                    guard let url else { return }
                    cameraSuccessCallback(nil, url)
                }
        }
        .alert(FlexHelper.goToSettings,
               isPresented: $viewModel.showSettingsAlert) {
            Button(FlexHelper.cancelButtonTitle) {}
            
            Button(FlexHelper.settingsButtonTitle) {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            }
        } message: {
            Text(FlexHelper.cameraPermissionAlert)
        }
    }
    
    private func hexColor(status: Bool = true) -> String {
        status ? FlexHelper.enabledHexColor: FlexHelper.disabledHexColor
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView {_,_  in }
    }
}
