import SwiftUI

public struct LaunchGridView: View {
    @ObservedObject public var viewModel: LaunchViewModel

    private let columns = [
        GridItem(.adaptive(minimum: 140, maximum: 180), spacing: 16)
    ]

    public init(viewModel: LaunchViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView {
            if viewModel.filteredItems.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: viewModel.searchText.isEmpty ? "plus.square.dashed" : "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary.opacity(0.6))
                        .padding(.top, 60)

                    if viewModel.searchText.isEmpty {
                        Text("Chưa có ứng dụng nào")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Bấm nút '+ Thêm' trên thanh công cụ để tạo nút khởi chạy mới.")
                            .font(.subheadline)
                            .foregroundColor(.secondary.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        Button(action: {
                            viewModel.isShowingAddSheet = true
                        }) {
                            Label("Thêm mục đầu tiên", systemImage: "plus")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 8)
                    } else {
                        Text("Không tìm thấy kết quả")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Không có mục nào khớp với từ khóa '\(viewModel.searchText)'")
                            .font(.subheadline)
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 280)
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.filteredItems) { item in
                        LaunchCardView(
                            item: item,
                            isEditMode: viewModel.isEditMode,
                            onLaunch: {
                                viewModel.launch(item)
                            },
                            onEdit: {
                                viewModel.editingItem = item
                            },
                            onDelete: {
                                viewModel.deleteItem(item)
                            }
                        )
                    }
                }
                .padding(20)
            }
        }
    }
}
