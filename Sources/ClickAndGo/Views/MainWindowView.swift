import SwiftUI

public struct MainWindowView: View {
    @StateObject private var viewModel = LaunchViewModel()

    public init() {}

    public var body: some View {
        ZStack(alignment: .bottom) {
            LaunchGridView(viewModel: viewModel)
                .frame(minWidth: 540, minHeight: 380)

            // Floating Toast Alert
            if let toast = viewModel.toastMessage {
                HStack(spacing: 8) {
                    Image(systemName: viewModel.isToastError ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                        .foregroundColor(viewModel.isToastError ? .yellow : .green)
                    Text(toast)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.85))
                        .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
                )
                .padding(.bottom, 20)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                HStack(spacing: 8) {
                    Image(systemName: "bolt.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.blue)
                    Text("ClickAndGo")
                        .font(.headline)
                }
            }

            ToolbarItem(placement: .automatic) {
                HStack(spacing: 12) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Tìm kiếm...", text: $viewModel.searchText)
                            .textFieldStyle(.plain)
                            .frame(width: 140)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.12)))

                    // Edit Mode Toggle
                    Button(action: {
                        withAnimation {
                            viewModel.isEditMode.toggle()
                        }
                    }) {
                        Image(systemName: viewModel.isEditMode ? "checkmark.circle.fill" : "slider.horizontal.3")
                            .foregroundColor(viewModel.isEditMode ? .blue : .primary)
                    }
                    .help(viewModel.isEditMode ? "Xong chỉnh sửa" : "Bật chế độ chỉnh sửa / xóa")

                    // Add Button
                    Button(action: {
                        viewModel.isShowingAddSheet = true
                    }) {
                        Label("Thêm nút", systemImage: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .sheet(isPresented: $viewModel.isShowingAddSheet) {
            ItemEditorSheet { newItem in
                viewModel.addItem(newItem)
            }
        }
        .sheet(item: $viewModel.editingItem) { item in
            ItemEditorSheet(item: item) { updatedItem in
                viewModel.updateItem(updatedItem)
            }
        }
    }
}
