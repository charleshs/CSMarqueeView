import UIKit

/**
 A view that continuously scrolls its content horizontally.
 */
public final class CSMarqueeView: UIView {
    // MARK: - Types

    /// The direction in which the content is scrolled.
    public enum Direction: String {
        /// Indicates scrolling from right to `left`.
        case left
        /// Indicates scrolling from left to `right`.
        case right
    }

    // MARK: - Vars

    /// Contents to be displayed by the `CSMarqueeView`.
    public var contentViews: [UIView] = [] {
        didSet {
            updateContent()
        }
    }

    /// The direction in which the content is scrolled. Default is `left`.
    public var direction: Direction = .left

    /// The speed of the scrolling of unit `CGFloat/sec`. Defaults to `30`.
    public var pointsPerSecond: CGFloat = 30

    /// The spacing between two adjacent content views.
    /// Unused if only one view presented in `contentViews`. Default value is `10`.
    public var spacing: CGFloat = 10 {
        didSet {
            updateContent()
        }
    }

    // MARK: - iVars

    /// A scroll view that houses the content to be scrolled.
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isUserInteractionEnabled = false
        scrollView.scrollsToTop = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    /// A `Timer` object responsible for the proceeding of marquee scrolling.
    private var timer: Timer?

    private let framesPerSecond: Double = 60

    // MARK: - Overrides

    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: superview)

        // Stop the timer if `MarqueeView` is removed from its superview.
        if newSuperview == nil { invalidateTimer() }
    }

    // MARK: - Initialzers

    /**
     Create an object of `MarqueeView`.
     - parameter pointsPerSecond: The speed of scrolling. Defaults to `30`.
     */
    public init(pointsPerSecond: CGFloat = 30) {
        self.pointsPerSecond = pointsPerSecond
        super.init(frame: .zero)
        initialise()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialise()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialise()
    }

    deinit {
        invalidateTimer()
    }

    // MARK: - APIs

    /// Start the marquee scrolling.
    public func startMarquee() {
        invalidateTimer()
        resetScrolling()

        let interval = 1 / framesPerSecond
        let timer = Timer(timeInterval: interval, target: self, selector: #selector(processMarquee), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
        timer.fire()
        self.timer = timer
    }

    // MARK: - Private Methods

    /// The shared initializer.
    private func initialise() {
        layer.masksToBounds = true

        addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    /// Invoked on timer ticks.
    @objc private func processMarquee() {
        let moveFactor: CGFloat = direction == .left ? 1 : -1
        let offsetPerMove = moveFactor * pointsPerSecond / CGFloat(framesPerSecond)

        scrollView.contentOffset.x += offsetPerMove

        if reachingScrollingEnd() { resetScrolling() }
    }

    /// Stop the marquee scrolling.
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }

    /// Set scroll view's `contentOffset.x` to the initial offset.
    private func resetScrolling() {
        scrollView.contentOffset.x = initialOffset(for: direction)
    }

    /// Calculate and return the initial `x` offset for the specified `Direction`.
    private func initialOffset(for direction: Direction) -> CGFloat {
        switch direction {
        case .left:
            return -scrollView.bounds.size.width
        case .right:
            return scrollView.contentSize.width
        }
    }

    /// Check if `contentOffset.x` of the scroll view reaches the end of scrolling.
    /// - Returns: `true` if reaching the end of scrolling.
    private func reachingScrollingEnd() -> Bool {
        (direction == .left && scrollView.contentOffset.x > scrollView.contentSize.width)
            || (direction == .right && scrollView.contentOffset.x < -scrollView.bounds.width)
    }

    /// Invoked when the content or layout is changed.
    private func updateContent() {
        configureContentViews()

        guard contentViews.count > 0 else { return }
        layoutIfNeeded()
        resetScrolling()
    }

    /// Replace scroll view's subviews with `currentViews` and position them as stacked with Auto Layout.
    private func configureContentViews() {
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        guard contentViews.count > 0 else { return }

        var constraints: [NSLayoutConstraint] = []
        var lastView: UIView?

        contentViews.forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(view)
            constraints += [
                view.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
                view.centerYAnchor.constraint(equalTo: centerYAnchor),
                bottomAnchor.constraint(greaterThanOrEqualTo: view.bottomAnchor),
            ]
            if let lastView = lastView {
                constraints.append(view.leadingAnchor.constraint(equalTo: lastView.trailingAnchor, constant: spacing))
            } else {
                constraints.append(view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor))
            }
            lastView = view
        }

        lastView.map {
            constraints.append($0.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor))
        }

        NSLayoutConstraint.activate(constraints)
    }
}
