//
//  PagingTabView.swift
//  ImageViewerPractice
//
//  Created by 박세웅 on 1/7/26.
//

import SwiftUI

struct PagingTabView<Page: View>: UIViewControllerRepresentable {
  @Binding var currentIndex: Int
  @Binding var scrollProgress: CGFloat
  let pages: [Page]
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  func makeUIViewController(context: Context) -> UIPageViewController {
    let pageVC = UIPageViewController(
      transitionStyle: .scroll,
      navigationOrientation: .horizontal,
      options: [UIPageViewController.OptionsKey.interPageSpacing: 40]
    )
    
    pageVC.dataSource = context.coordinator
    pageVC.delegate = context.coordinator
    
    if let scrollView = pageVC.view.subviews.compactMap({ $0 as? UIScrollView }).first {
      scrollView.delegate = context.coordinator
    }
    
    context.coordinator.controllers = pages.map {
      let controller = UIHostingController(rootView: $0)
      controller.view.backgroundColor = .clear
      return controller
    }
    
    if !context.coordinator.controllers.isEmpty {
      let initialVC = context.coordinator.controllers[currentIndex]
      initialVC.view.backgroundColor = .clear
      pageVC.setViewControllers([initialVC], direction: .forward, animated: false, completion: nil)
    }
    
    return pageVC
  }
  
  func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
    if context.coordinator.controllers.count != pages.count {
      context.coordinator.controllers = pages.map {
        let controller = UIHostingController(rootView: $0)
        controller.view.backgroundColor = .clear
        return controller
      }
      
      if !context.coordinator.controllers.isEmpty && currentIndex < context.coordinator.controllers.count {
        pageViewController.setViewControllers([context.coordinator.controllers[currentIndex]], direction: .forward, animated: false, completion: nil)
      }
    }
    
    if context.coordinator.lastIndex != currentIndex {
      guard currentIndex >= 0, currentIndex < context.coordinator.controllers.count else { return }
      
      let direction: UIPageViewController.NavigationDirection = currentIndex >= context.coordinator.lastIndex ? .forward : .reverse
      DispatchQueue.main.async {
        self.scrollProgress = 0.0
      }
      
      pageViewController.setViewControllers([
        context.coordinator.controllers[currentIndex]
      ], direction: direction, animated: true) { _ in
        context.coordinator.updateParentStates(newIndex: currentIndex)
      }
    }
  }
  
  class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate {
    var parent: PagingTabView
    var controllers: [UIViewController]
    var lastIndex: Int
    
    init(_ parent: PagingTabView) {
      self.parent = parent
      self.controllers = []
      self.lastIndex = parent.currentIndex
    }
    
    func updateParentStates(newIndex: Int) {
      DispatchQueue.main.async { [weak self] in
        self?.parent.currentIndex = newIndex
        self?.lastIndex = newIndex
        self?.parent.scrollProgress = 0.0
      }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
      guard let index = controllers.firstIndex(of: viewController), index > 0 else { return nil }
      return controllers[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
      guard let index = controllers.firstIndex(of: viewController), index + 1 < controllers.count else { return nil }
      return controllers[index + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
      if completed {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = controllers.firstIndex(of: currentViewController) {
          updateParentStates(newIndex: currentIndex)
        }
      }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
      let offset = scrollView.contentOffset.x
      let width = scrollView.bounds.width

      guard width > 0 else { return }
      let currentScroll = offset / width - 1.0

      // Only disable bounces at the actual boundaries (trying to scroll beyond)
      if (parent.currentIndex == 0 && offset <= 0) || (parent.currentIndex == parent.pages.count - 1 && offset >= width * 2) {
        if scrollView.bounces {
          scrollView.bounces = false
        }
      } else {
        if !scrollView.bounces {
          scrollView.bounces = true
        }
      }

      DispatchQueue.main.async { [weak self] in
        self?.parent.scrollProgress = currentScroll
      }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
      scrollView.bounces = true
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
      scrollView.bounces = true
    }
  }
}
