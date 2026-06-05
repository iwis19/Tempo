//
//  StyleTemplates.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-04-16.
//

import SwiftUI

var greetingText: String {
    let hour = Calendar.current.component(.hour, from: Date())
    
    switch hour {
        case 0..<12: return "Good morning"
        case 12..<18: return "Good afternoon"
        case 18...: return "Good evening"
        default: return "Hello"
    }
}


// PAGE CONTAINERS
// <Content: View> indicates that it is generic over some content, but content must also follow View protocol, meaning that this container can hold any child UI inside it
struct PageContainer <Content: View>: View {
    let scrollable: Bool
    let bottomInset: CGFloat // how much space is added at the bottom, CGFloat is meant for UI / drawing floating-point number
    let content: Content // page-specific UI i pass in
    
    // @ViewBuilder lets me write multiple UI views naturally inside this container call, content() stores the resulting view
    // "content: () -> Content means that this doesnt take arguments, and that it returns Content type
    init(scrollable: Bool = true, bottomInset: CGFloat = 0, @ViewBuilder content: () -> Content) {
        self.scrollable = scrollable
        self.bottomInset = bottomInset
        self.content = content()
    }
    
    var body: some View{
        ZStack {
            PageBackground()
            
            if scrollable {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        content
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 22)
                    .padding(.top, 28)
                    .padding(.bottom, bottomInset)
                    .offset(y: -20)
                }
                .scrollBounceBehavior(.basedOnSize, axes: Axis.Set.vertical)
            }
            else {
                VStack(alignment: .leading, spacing: 22) {
                    content
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 22)
                .padding(.top, 28)
                .padding(.bottom, bottomInset)
                .offset(y: -20)
            }
        }
    }
}


// PROMINENT GREEN CARD IN MOST PAGES
struct MainCard <Content: View>: View{
    let profit: Bool
    let content: Content
    init(
        positive: Bool,
        @ViewBuilder content: () -> Content
    ) {
        self.profit = positive
        self.content = content()
    }
    
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10){
            content
        }
        .padding(22) // add inner space around the view's content by 22 px, rather than all view elements in the stack
        .background(
            profit ? positiveGradient() : negativeGradient()
        )
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous)) // cuts the entire View into a roundedrectangle
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        } // creates a subtle outline for this roundedrectangle
        .shadow(color: Color("tempoShadow").opacity(0.18), radius: 22, y: 12) // adds a shadow around the shape
    }
}


// TRANSLUCENT BOX UNDER MAIN CARD
struct MainCardBox: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.62))
            
            Text(description)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(.white.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}


// STATUS BADGE
struct MainCardStatusBadge : View {
    let text: String
    let positive: Bool
    
    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(positive ? Color("tempoDeepGreen") : Color("tempoWineRed"))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(positive ? Color("tempoGlow") : Color("tempoLossWash"))
            .clipShape(Capsule())
    }
}


// WHITE SURFACE CARDS FOR DASHBOARD, SETTINGS ETC
struct SurfaceCard <Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content:() -> Content) {
        self.content = content()
    }
    
    var body: some View{
        VStack (alignment: .leading, spacing: 14){
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color("tempoLeaf").opacity(0.10), lineWidth: 1)
        }
        
    }
}


// SECTION TITLES
struct SectionTitle : View {
    let title: String
    let subtitle: String?
    
    var body : some View {
        Text(title)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(Color("tempoInk"))
        
        if let subtitle{
            Text(subtitle)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color("tempoInk").opacity(0.62))
        }
    }
}


// SPECIFIC SETTING LAYOUT
struct SettingRow : View {
    let title: String
    let icon: String
    let description: String
    let details: String
    
    var body : some View {
        HStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color("tempoSoftMint").opacity(0.30))
                .frame(width: 48, height: 48)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color("tempoDeepGreen"))
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color("tempoInk"))
                    .offset(y:2)

                Text(description)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color("tempoInk").opacity(0.58))
            }
            
            Spacer()
            
            Text(details)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color("tempoDeepGreen"))
        }
    }
}


// COLOR AND DISPLAY PREVIEW FOR GAIN/LOSS
struct PreviewRow : View {
    
    let title: String
    let value: String
    let tint: Color
    let background: Color
    
    var body : some View{
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color("tempoInk"))

            Spacer()

            Text(value)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(tint)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(background.opacity(0.70))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}


// CARD FOR EACH TIME CATEGORY EXPLANATION
struct TimeCategoryCard: View {
    let title: String
    let summary: String
    let tint: Color
    let examples: [String]

    var body: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(tint)

                    Spacer()

                    Circle()
                        .fill(tint.opacity(0.18))
                        .frame(width: 14, height: 14)
                }

                Text(summary)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color("tempoInk").opacity(0.68))

                ForEach(examples, id: \.self) { example in
                    HStack(alignment: .top, spacing: 10) {
                        Circle()
                            .fill(tint.opacity(0.85))
                            .frame(width: 7, height: 7)
                            .padding(.top, 6)

                        Text(example)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color("tempoInk"))
                    }
                }
            }
            .offset(x:3)
            .padding(3)
        }
    }
}


// ROWS FOR EACH STATEMENT EXPLANATION
struct StatementFlowStepRow: View {
    let number: String
    let title: String
    let bodyText: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color("tempoDeepGreen"))
                .frame(width: 28, height: 28)
                .background(Color("tempoSoftMint").opacity(0.50))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color("tempoInk"))

                Text(bodyText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color("tempoInk").opacity(0.65))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// PAGE BACKGROUNDS
struct PageBackground: View {
    var body: some View{
        
        ZStack {
            LinearGradient(colors: [Color("tempoShell"), Color("tempoShell"), Color.white ,Color("tempoShell"), Color("tempoShell")], startPoint: .topTrailing, endPoint: .bottomLeading)
                .ignoresSafeArea()
            
//            Circle()
//                .fill(Color("tempoSoftMint").opacity(0.74))
//                .blur(radius: 70)
//                .frame(width: 260, height: 260)
//                .offset(x: 145, y: -250)
//            
//            RoundedRectangle(cornerRadius: 70, style: .continuous)
//                .fill(Color.white.opacity(0.58))
//                .frame(width: 260, height: 340)
//                .rotationEffect(.degrees(24))
//                .offset(x: 165, y: -140)
//            
//            RoundedRectangle(cornerRadius: 56, style: .continuous)
//                .stroke(Color("tempoLeaf").opacity(0.16), lineWidth: 1)
//                .frame(width: 210, height: 210)
//                .rotationEffect(.degrees(-18))
//                .offset(x: -165, y: 290)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}


// PAGE HEADERS
struct PageHeader: View {
    let eyebrow: String
    let title: String?
    let subtitle: String?
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10){
            Text(eyebrow)
                .foregroundStyle(Color("tempoInk").opacity(0.58))
                .font(.system(size: 14, weight: .semibold))
            
            if let title {
                Text(title)
                    .foregroundStyle(Color("tempoInk"))
                    .font(.custom("Syne-Regular", size:34))
                // if userName is too long, it caps this entire line to max 2 lines, and uses ... to replace the exceeding characters
                    .lineLimit(2)
                    .truncationMode(.tail)
            }
            
            // similar to python's "if subtitle:", it checks if value equals to nil or not, if not, it unwraps it, but it is a safer method than doing it normally
            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color("tempoInk").opacity(0.68))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}


// VISUAL DRAG INDICATOR
struct DragIndicator: View {
    var body: some View {
        Capsule()
            .fill(Color("tempoInk").opacity(0.12))
            .frame(width:52, height:5)
    }
}


struct NavigationButton: View {
    let icon: String
    let action: () -> Void
    
    init(
        icon: String,
        action: @escaping () -> Void) {
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button (action: action) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color("tempoDeepGreen"))
                .frame(width: 50, height: 50)
                .background(Color("tempoSoftMint").opacity(0.36))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}


// ACTION BUTTON
struct ActionButton: View{
    let title: String
    let light: Bool
    
    // basically a piece of passable code stored into this action variable that does something, and it takes no params since (), and returns nothing since Void
    let action: () -> Void
    
    init(
        title: String,
        light: Bool = true,
        action: @escaping () -> Void
    ){
        self.title = title
        self.light = light
        self.action = action
    }

    var body: some View {
        
        // with action: action, it essentially means that the button stores code that takes no parameters and has no return values, but a piece of code that runs when the button goes off
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(light ? Color("tempoInk") : Color.white.opacity(0.84))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(light ? Color.white.opacity(0.84) : Color("tempoInk"))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                
        }
    }
}


// REWORKED NAVIGATION BAR
struct BetterNavigationBar: View {
    @Binding var selectedTab: Tab

    var body: some View {
        HStack (alignment: .center) {
            // TODO: add more pages here when completed
            tabButton(for: .home)
            tabButton(for: .today)
                .offset(y:-1.5)
            
            tabButton(for: .history)
            tabButton(for: .profile)
            
        }
        .padding(.horizontal, 24)
        .frame(height: 72)
        .background(.white.opacity(0.96))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color("tempoLeaf").opacity(0.10), lineWidth: 1)
        }
        .shadow(color: Color("tempoShadow").opacity(0.08), radius: 18, y: 10)
    }
    
    // for is NOT a loop here, it's just a label to make function call look nice: tabButton(for: .dashboard)
    private func tabButton(for tab: Tab) -> some View {
        let isSelected = selectedTab == tab

        return Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 6) {
                Image(systemName: tab.icon)
                    .font(.system(size: 18, weight: .semibold))

                Text(tab.title)
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundStyle(isSelected ? Color("tempoDeepGreen") : Color("tempoInk").opacity(0.45))
        }
    }
}


struct LedgerRow: View {
    let activity: Activity
    let amount: Double
    
    private var tone: Flowtone { activity.category.tone }

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            Circle()
                .fill(tone.background.opacity(0.95))
                .frame(width: 46, height: 46)
                .overlay {
                    Image(systemName: activity.category.icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(tone.tint)
                }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(activity.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color("tempoInk"))
                
                HStack(spacing: 6) {
                    Text(TimeFormatter.minuteCountString(minutes: activity.durationMinutes))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color("tempoInk").opacity(0.58))
                    
                    Circle()
                        .fill(Color("tempoInk").opacity(0.24))
                        .frame(width: 4, height: 4)
                    
                    Text(activity.category.title)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color("tempoInk").opacity(0.58))
                }
            }
            
            Spacer()
            
            Text(CurrencyFormatter.string(amount, shorten: true, alwaysShowSign: true))
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(tone.tint)
            
        }
        
    }
    
}


struct summaryCard: View {
    let title: String
    let value: String
    let subtitle: String
    let tint: Color
    let background: Color
    var gain: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size:12, weight: .semibold))
                .foregroundStyle(Color("tempoInk").opacity(0.58))
            
            HStack (alignment: .firstTextBaseline, spacing: 1) {
                Text(valueSign)
                    .font(.system(size:14, weight: .bold))
                    .foregroundStyle(tint)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                
                Text(valueAmount)
                    .font(.custom("Syne-Regular", size: 24))
                    .foregroundStyle(tint)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .allowsTightening(true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)
        
            
            Text(subtitle)
                .font(.system(size:13, weight: .medium))
                .foregroundStyle(Color("tempoInk").opacity(0.64))
                .padding(.top, 8)

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(background.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color("tempoInk").opacity(0.10), lineWidth: 1)
        }
    }
    
    private var valueSign: String {
        return gain ? "+" : "-"
    }
    
    private var valueAmount: String {
        if value.hasPrefix("-") || value.hasPrefix("+") {
            return String(value.dropFirst())
        }
        return value
    }
}


func positiveGradient(graph: Bool = false) -> LinearGradient {
    LinearGradient(
        colors: [
            Color("tempoDeepGreen"),
            Color("tempoLeaf")
        ],
        startPoint: graph ? .bottom : .topLeading,
        endPoint: graph ? .top : .bottomTrailing)
}

func negativeGradient(graph: Bool = false) -> LinearGradient {
    LinearGradient(
        colors: [
            Color("tempoWineRed"),
            Color("tempoLossRed")
        ],
        startPoint: graph ? .top : .topLeading,
        endPoint: graph ? .bottom : .bottomTrailing
    )
}

struct ActivityRow: View {
    @Binding var activity: Activity
    let amount: Double
    let onDelete: () -> Void

    var body: some View {
        SurfaceCard {
            LedgerRow(activity: activity, amount: amount)
            
            HStack(spacing: 10) {
                ForEach(ActivityCategory.allCases) { category in
                    let tone = category.tone
                    
                    Button(action: {
                        activity.category = category
                    }) {
                        Text(category.title)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(activity.category == category ? .white : tone.tint)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(activity.category == category ? tone.tint : tone.background)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color("tempoLossRed"))
                        .padding(10)
                        .background(Color("tempoLossWash").opacity(0.5))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
    }
}


struct CategoryMixBar: View {
    
    let totalTime: Int // in mins
    let percent: Double // in decimals 0-1
    let amount: Double
    let activity: ActivityCategory
    
    var percentIn100: Int {
        return Int((percent * 100).rounded())
    }
    
    var body: some View {
        
        VStack {
            HStack (alignment: .center, spacing: 14){
                Circle()
                    .fill(activity.tone.background.opacity(0.95))
                    .frame(width: 46, height: 46)
                    .overlay {
                        Image(systemName: activity.icon)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(activity.tone.tint)
                    }
                
                VStack (alignment: .leading, spacing: 4) {
                    Text(activity.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color("tempoInk"))
                    
                    Text(TimeFormatter.minuteCountString(minutes: totalTime))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color("tempoInk").opacity(0.58))
                }
                
                Spacer()
                
                VStack (alignment: .trailing, spacing: 4) {
                    Text("\(CurrencyFormatter.string(amount, shorten: true, alwaysShowSign: true))")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(activity.tone.tint)
                    
                    Text("\(percentIn100)%")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color("tempoInk").opacity(0.58))
                }
            }
            GeometryReader { area in
                
                ZStack (alignment: .leading){
                    Capsule()
                        .fill(Color("tempoNeutralCard"))

                    Capsule()
                        .fill(activity.tone.tint.opacity(activity == .required ? 0.44 : 0.78))
                        .frame(width: area.size.width * min(max(percent, 0), 1))
                }
            }
            .frame(height: 7)
        }
        .padding(12)
        .background(activity.tone.background.opacity(0.65))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay{
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(activity.tone.background, lineWidth: 1)
        }
    }
    
}

struct statementCompactRow: View {
    let statement: StatementSummary
    
    var tone: Flowtone {
        switch statement.netTotal {
        case ..<0:
            return .negative
        case 0:
            return .neutral
        default:
            return .positive
        }
    }
    
    var body: some View {
        SurfaceCard {
            VStack {
                HStack {
                    VStack (alignment: .leading, spacing: 6){
                        Text(statement.date)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color("tempoInk"))
                        
                        Text("\(statement.entries) entries")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color("tempoInk").opacity(0.58))
                    }
                    .padding(.leading, 3)
                    
                    Spacer()
                    
                    Text(CurrencyFormatter.string(statement.netTotal, shorten: true, alwaysShowSign: true))
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(tone.tint)
                        .padding(.trailing, 3)
                }
                
                HStack {
                    statementCompactRowBox(
                        activityType: .earned,
                        amount: statement.earnedMinutes // place holder
                    )
                    statementCompactRowBox(
                        activityType: .required,
                        amount: statement.requiredMinutes // place holder
                    )
                    statementCompactRowBox(
                        activityType: .spent,
                        amount: statement.spentMinutes // place holder
                    )
                }
                
            }
        }
    }
}

struct statementCompactRowBox: View {
    let activityType: ActivityCategory
    let amount: String // time in minutes
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(activityType.title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color("tempoInk").opacity(0.58))
                .padding(.bottom, 3)
            
            Text(amount)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(activityType.tone.tint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(activityType.tone.background)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
