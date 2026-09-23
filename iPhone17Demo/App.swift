import SwiftUI
import WebKit

@main
struct iPhone17DemoApp: App {
    var body: some Scene {
        WindowGroup { PhoneShell() }
    }
}

enum DemoScreen: String, CaseIterable, Identifiable {
    case phone, messages, safari, photos, camera, settings, calculator, notes, clock, music, weather, maps
    var id: String { rawValue }
    var title: String {
        switch self {
        case .phone: return "Telefon"
        case .messages: return "Zprávy"
        case .safari: return "Safari"
        case .photos: return "Fotky"
        case .camera: return "Fotoaparát"
        case .settings: return "Nastavení"
        case .calculator: return "Kalkulačka"
        case .notes: return "Poznámky"
        case .clock: return "Hodiny"
        case .music: return "Hudba"
        case .weather: return "Počasí"
        case .maps: return "Mapy"
        }
    }
    var icon: String {
        switch self {
        case .phone: return "phone.fill"
        case .messages: return "message.fill"
        case .safari: return "safari.fill"
        case .photos: return "photo.on.rectangle.angled"
        case .camera: return "camera.fill"
        case .settings: return "gearshape.fill"
        case .calculator: return "plus.forwardslash.minus"
        case .notes: return "note.text"
        case .clock: return "clock.fill"
        case .music: return "music.note"
        case .weather: return "cloud.sun.fill"
        case .maps: return "map.fill"
        }
    }
    var color: Color {
        switch self {
        case .phone: return .green
        case .messages: return .green
        case .safari: return .blue
        case .photos: return .pink
        case .camera: return .gray
        case .settings: return .gray
        case .calculator: return .orange
        case .notes: return .yellow
        case .clock: return .black
        case .music: return .red
        case .weather: return .cyan
        case .maps: return .green
        }
    }
}

struct PhoneShell: View {
    @State private var locked = true
    @State private var active: DemoScreen? = nil
    @State private var showControl = false
    @AppStorage("wallpaper") private var wallpaper = 0
    @AppStorage("darkMode") private var darkMode = true

    var body: some View {
        ZStack {
            wallpaperView.ignoresSafeArea()
            if locked { lockScreen }
            else if let app = active { appView(app) }
            else { homeScreen }

            if showControl && !locked {
                Color.black.opacity(0.25).ignoresSafeArea().onTapGesture { withAnimation { showControl = false } }
                controlCenter.transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .preferredColorScheme(darkMode ? .dark : .light)
        .statusBarHidden(true)
    }

    private var wallpaperView: some View {
        ZStack {
            LinearGradient(colors: wallpaper == 1 ? [.black,.purple,.cyan] : wallpaper == 2 ? [.black,.mint,.blue] : [.black,.indigo,.pink], startPoint: .topLeading, endPoint: .bottomTrailing)
            Circle().fill((wallpaper == 1 ? Color.cyan : Color.pink).opacity(0.55)).frame(width: 310,height:310).blur(radius:70).offset(x:130,y:-220)
            Circle().fill((wallpaper == 2 ? Color.mint : Color.blue).opacity(0.5)).frame(width:360,height:360).blur(radius:80).offset(x:-150,y:260)
        }
    }

    private var topBar: some View {
        HStack {
            TimelineView(.periodic(from: .now, by: 1)) { context in
                Text(context.date.formatted(date: .omitted,time: .shortened)).font(.system(size:14,weight:.semibold))
            }
            Spacer()
            HStack(spacing:6) { Image(systemName:"cellularbars"); Image(systemName:"wifi"); Image(systemName:"battery.100percent") }
                .font(.system(size:13,weight:.semibold))
        }
        .foregroundStyle(.white).padding(.horizontal,18).frame(height:38)
        .overlay(alignment:.top) { Capsule().fill(.black).frame(width:122,height:33).padding(.top,2) }
    }

    private var lockScreen: some View {
        VStack(spacing:0) {
            topBar
            Spacer().frame(height:45)
            Text(Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide))).font(.headline).foregroundStyle(.white.opacity(0.85))
            TimelineView(.periodic(from:.now,by:1)) { c in
                Text(c.date.formatted(date:.omitted,time:.shortened)).font(.system(size:82,weight:.thin,design:.rounded)).foregroundStyle(.white)
            }
            Spacer()
            HStack { circleButton("flashlight.off.fill"); Spacer(); circleButton("camera.fill") }.padding(.horizontal,44)
            Text("Přejeď nahoru pro odemknutí").font(.caption).foregroundStyle(.white.opacity(0.85)).padding(.top,16)
            Capsule().fill(.white).frame(width:135,height:5).padding(.vertical,12)
        }
        .contentShape(Rectangle()).gesture(DragGesture(minimumDistance:25).onEnded { v in if v.translation.height < -20 { withAnimation(.spring()) { locked=false } } }).onTapGesture { withAnimation { locked=false } }
    }

    private var homeScreen: some View {
        VStack(spacing:0) {
            topBar
            HStack {
                VStack(alignment:.leading,spacing:2) { Text("iPhone 17 Pro").font(.title2.bold()); Text("iOS 26 Demo").font(.caption).opacity(0.75) }
                Spacer()
                Button { withAnimation { showControl.toggle() } } label: { Image(systemName:"slider.horizontal.3").font(.title2).foregroundStyle(.white) }
            }.foregroundStyle(.white).padding(.horizontal,20).padding(.vertical,12)

            LazyVGrid(columns:Array(repeating:GridItem(.flexible()),count:4),spacing:22) {
                ForEach(DemoScreen.allCases) { app in
                    Button { withAnimation(.spring(response:0.35,dampingFraction:0.85)) { active=app } } label: {
                        VStack(spacing:6) {
                            RoundedRectangle(cornerRadius:15).fill(app.color.gradient).frame(width:58,height:58).overlay(Image(systemName:app.icon).font(.system(size:27,weight:.semibold)).foregroundStyle(app == .notes ? .black : .white)).shadow(radius:4)
                            Text(app.title).font(.caption2).foregroundStyle(.white).lineLimit(1)
                        }
                    }.buttonStyle(.plain)
                }
            }.padding(.horizontal,12).padding(.top,14)
            Spacer()
            HStack(spacing:24) {
                ForEach([DemoScreen.phone,.safari,.messages,.music]) { app in
                    Button { withAnimation { active=app } } label: { RoundedRectangle(cornerRadius:16).fill(app.color.gradient).frame(width:60,height:60).overlay(Image(systemName:app.icon).font(.system(size:28,weight:.semibold)).foregroundStyle(.white)) }.buttonStyle(.plain)
                }
            }.padding(.horizontal,22).padding(.vertical,13).background(.ultraThinMaterial,in:RoundedRectangle(cornerRadius:28)).padding(.bottom,14)
            Capsule().fill(.white).frame(width:135,height:5).padding(.bottom,8)
        }
    }

    @ViewBuilder private func appView(_ app: DemoScreen) -> some View {
        VStack(spacing:0) {
            HStack {
                Button { withAnimation { active=nil } } label: { Image(systemName:"chevron.left").font(.title3.bold()) }
                Text(app.title).font(.headline)
                Spacer()
                Text("iPhone 17").font(.caption).foregroundStyle(.secondary)
            }.padding(.top,12).padding(.horizontal,16).frame(height:58).background(.ultraThinMaterial)
            Group {
                switch app {
                case .safari: WebView(url: URL(string:"https://www.google.com")!)
                case .maps: WebView(url: URL(string:"https://www.openstreetmap.org/#map=12/49.8209/18.2625")!)
                case .calculator: CalculatorView()
                case .settings: SettingsView(wallpaper:$wallpaper,darkMode:$darkMode,lock:{ locked=true; active=nil })
                case .notes: NotesView()
                case .clock: ClockView()
                case .messages: MessagesView()
                case .phone: PhoneView()
                case .music: MusicView()
                case .weather: WeatherView()
                case .photos: PhotosView()
                case .camera: CameraView()
                }
            }.frame(maxWidth:.infinity,maxHeight:.infinity).background(Color(uiColor:.systemBackground))
            Capsule().fill(Color.primary.opacity(0.8)).frame(width:135,height:5).padding(.vertical,8)
        }.ignoresSafeArea(edges:.top)
    }

    private var controlCenter: some View {
        VStack(spacing:14) {
            HStack { Text("Ovládací centrum").font(.headline); Spacer(); Button("Hotovo") { withAnimation { showControl=false } } }
            HStack(spacing:14) {
                controlTile("airplane","Letadlo",.orange)
                controlTile("wifi","Wi‑Fi",.blue)
                controlTile("bolt.horizontal.fill","Bluetooth",.blue)
                controlTile("moon.fill","Režim",.indigo)
            }
            HStack { Image(systemName:"sun.max.fill"); Slider(value:.constant(0.7)); Image(systemName:"speaker.wave.2.fill") }
        }.padding(18).background(.ultraThinMaterial,in:RoundedRectangle(cornerRadius:28)).padding(.horizontal,14).frame(maxHeight:.infinity,alignment:.top).padding(.top,55)
    }

    private func controlTile(_ icon:String,_ text:String,_ color:Color) -> some View { VStack { Image(systemName:icon).font(.title3); Text(text).font(.caption2) }.frame(maxWidth:.infinity).padding(.vertical,14).background(color.opacity(0.85),in:RoundedRectangle(cornerRadius:18)).foregroundStyle(.white) }
    private func circleButton(_ icon:String) -> some View { Circle().fill(.black.opacity(0.38)).frame(width:52,height:52).overlay(Image(systemName:icon).foregroundStyle(.white)) }
}

struct WebView: UIViewRepresentable {
    let url: URL
    func makeUIView(context: Context) -> WKWebView { let v=WKWebView(); v.allowsBackForwardNavigationGestures=true; v.load(URLRequest(url:url)); return v }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

struct SettingsView: View {
    @Binding var wallpaper:Int
    @Binding var darkMode:Bool
    let lock:()->Void
    @State private var wifi=true
    @State private var bluetooth=true
    var body: some View {
        Form {
            Section { HStack { Circle().fill(.blue.gradient).frame(width:55,height:55).overlay(Image(systemName:"person.fill").foregroundStyle(.white)); VStack(alignment:.leading){Text("Matias").font(.headline);Text("iPhone 17 Pro").foregroundStyle(.secondary)} } }
            Section { Toggle("Wi‑Fi",isOn:$wifi); Toggle("Bluetooth",isOn:$bluetooth); Toggle("Tmavý režim",isOn:$darkMode) }
            Section("Tapeta") { Picker("Styl",selection:$wallpaper) { Text("Neon").tag(0); Text("Fialová").tag(1); Text("Mint").tag(2) }.pickerStyle(.segmented) }
            Section("Informace") { LabeledContent("Model",value:"iPhone 17 Pro"); LabeledContent("Systém",value:"iOS 26 Demo"); LabeledContent("Kapacita",value:"256 GB") }
            Section { Button("Zamknout iPhone",role:.destructive,action:lock) }
        }
    }
}

struct CalculatorView: View {
    @State private var text="0"
    let keys=["7","8","9","÷","4","5","6","×","1","2","3","−","0",".","C","+"]
    var body: some View { VStack { Spacer(); Text(text).font(.system(size:64,weight:.light,design:.rounded)).frame(maxWidth:.infinity,alignment:.trailing).padding(); LazyVGrid(columns:Array(repeating:GridItem(.flexible()),count:4),spacing:12) { ForEach(keys,id:\.self){ k in Button { if k=="C"{text="0"} else { text = text=="0" ? k : text+k } } label:{ Text(k).font(.title2.bold()).frame(maxWidth:.infinity).frame(height:62).background(k=="+" || k=="−" || k=="×" || k=="÷" ? Color.orange : Color.secondary.opacity(0.22),in:Circle()) } } }.padding(); Spacer().frame(height:18) }.padding(.horizontal,8) }
}

struct NotesView: View { @AppStorage("noteText") private var note="Moje poznámka\n\nTohle je funkční iPhone 17 demo v Appetize."; var body: some View { TextEditor(text:$note).font(.title3).padding() } }
struct ClockView: View { var body: some View { VStack(spacing:14){ Spacer(); TimelineView(.periodic(from:.now,by:1)){c in Text(c.date.formatted(date:.omitted,time:.standard)).font(.system(size:55,weight:.thin,design:.monospaced))}; Text(Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide))).foregroundStyle(.secondary); Spacer() } } }
struct MessagesView: View { @State private var text=""; @State private var msgs=["Ahoj 👋","Tohle je funkční demo Zpráv."]; var body: some View { VStack { ScrollView { ForEach(msgs,id:\.self){m in HStack { Spacer(); Text(m).padding(12).background(.blue,in:RoundedRectangle(cornerRadius:18)).foregroundStyle(.white) }.padding(.horizontal) } }; HStack { TextField("Zpráva",text:$text).textFieldStyle(.roundedBorder); Button { if !text.isEmpty { msgs.append(text); text="" } } label:{Image(systemName:"arrow.up.circle.fill").font(.title)} }.padding() } } }
struct PhoneView: View { @State private var number=""; var body: some View { VStack(spacing:18){ Spacer(); Text(number.isEmpty ? "Zadej číslo" : number).font(.largeTitle.monospacedDigit()); LazyVGrid(columns:Array(repeating:GridItem(.flexible()),count:3),spacing:14){ForEach(["1","2","3","4","5","6","7","8","9","*","0","#"],id:\.self){n in Button { number += n } label:{Text(n).font(.title).frame(width:70,height:70).background(Color.secondary.opacity(0.18),in:Circle())}}}; Button { } label:{Image(systemName:"phone.fill").font(.title).frame(width:70,height:70).background(.green,in:Circle()).foregroundStyle(.white)}; Spacer() } } }
struct MusicView: View { @State private var playing=false; var body: some View { VStack(spacing:24){Spacer(); RoundedRectangle(cornerRadius:28).fill(LinearGradient(colors:[.pink,.purple,.blue],startPoint:.topLeading,endPoint:.bottomTrailing)).aspectRatio(1,contentMode:.fit).overlay(Image(systemName:"waveform").font(.system(size:70)).foregroundStyle(.white)).padding(40); Text("NEZLOMILI MĚ").font(.title2.bold()); Text("ByMatiass").foregroundStyle(.secondary); Button {playing.toggle()} label:{Image(systemName:playing ? "pause.circle.fill":"play.circle.fill").font(.system(size:64))}; Spacer()} } }
struct WeatherView: View { var body: some View { ZStack { LinearGradient(colors:[.blue,.cyan],startPoint:.top,endPoint:.bottom).ignoresSafeArea(); VStack(spacing:8){Text("Ostrava").font(.title.bold());Text("18°").font(.system(size:88,weight:.thin));Image(systemName:"cloud.sun.fill").font(.system(size:55)).symbolRenderingMode(.multicolor);Text("Polojasno");Text("H: 21°  L: 12°").opacity(0.8)}.foregroundStyle(.white) } } }
struct PhotosView: View { let icons=["photo","camera.macro","sun.max","moon.stars","building.2","car","figure.walk","airplane"]; var body: some View { ScrollView { LazyVGrid(columns:[GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible())],spacing:3){ForEach(Array(icons.enumerated()),id:\.offset){i,item in Rectangle().fill([Color.pink,.blue,.purple,.orange,.green][i%5].gradient).aspectRatio(1,contentMode:.fit).overlay(Image(systemName:item).font(.title).foregroundStyle(.white))}} } } }
struct CameraView: View { @State private var flash=false; var body: some View { ZStack { Color.black.ignoresSafeArea(); LinearGradient(colors:[.black,.indigo.opacity(0.8),.black],startPoint:.top,endPoint:.bottom).ignoresSafeArea(); VStack { HStack { Button{flash.toggle()}{Image(systemName:flash ? "bolt.fill":"bolt.slash.fill")}; Spacer(); Text("FOTO").font(.caption.bold()) }.padding().foregroundStyle(.white); Spacer(); Image(systemName:"camera.aperture").font(.system(size:110)).foregroundStyle(.white.opacity(0.5)); Spacer(); Button{} label:{Circle().stroke(.white,lineWidth:5).frame(width:76,height:76).overlay(Circle().fill(.white).padding(7))}.padding(.bottom,25) } } } }
