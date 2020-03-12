//
//  AppDelegate.swift
//  Clients
//
//  Created by Максим Голов on 14.01.2019.
//  Copyright © 2019 Максим Голов. All rights reserved.
//

import UIKit
import CoreData
import CallKit

/*
 TODO: LIST
    1. Завершить переход на Foundation.Date
    2. Переписать код, связанный с Core Data
    3. Закончить переход на MVVM
    4. Использовать Combine / RxSwift
    5. ...
 */

// swiftlint: disable all
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppSettings.shared.registerDefaults()

        // MARK: Загрузка тестовых данных
        if ClientRepository.isEmpty {
            initializeData()
            CoreDataManager.shared.saveContext()
        }
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        CoreDataManager.shared.saveContext()
        CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: "MaximGolov.Clients.ClientsCallExtension")
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if url.scheme == "clients" && url.host == "todayExtension" {
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
            let visit = VisitRepository.visit(withId: urlComponents!.queryItems!.first!.value!)!

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let visitInfoController = storyboard.instantiateViewController(withIdentifier: "VisitInfoController") as! VisitInfoController
            visitInfoController.visit = visit

            let tabBarController = window!.rootViewController as! UITabBarController
            let navigationController = tabBarController.selectedViewController as! UINavigationController
            navigationController.pushViewController(visitInfoController, animated: true)
        }
        return true
    }

    private func initializeData() {
        let strengthening = AdditionalService(name: "Укрепление", cost: 200, duration: TimeInterval.zero)
        let nailExtension = AdditionalService(name: "Наращивание", cost: 400, duration: TimeInterval(hours: 1))
        let withoutDesign = AdditionalService(name: "Без дизайна", cost: -200, duration: TimeInterval(minutes: -30))
        let removal = AdditionalService(name: "Снятие", cost: 50, duration: TimeInterval.zero)
        let withoutCoating = AdditionalService(name: "Без покрытия", cost: -900, duration: TimeInterval(hours: -1, minutes: -30))
        let lashes2D = AdditionalService(name: "2D", cost: 200, duration: TimeInterval.zero)
        let lashes3D = AdditionalService(name: "3D", cost: 400, duration: TimeInterval(hours: 1))
        let lashes4D = AdditionalService(name: "4D", cost: 600, duration: TimeInterval(hours: 2))

        let manicure = Service(color: .systemTeal, name: "Маникюр", cost: 1400, duration: TimeInterval(hours: 3), additionalServices: [strengthening, nailExtension, withoutDesign, removal, withoutCoating])
        let brows = Service(color: .systemGreen, name: "Брови", cost: 700, duration: TimeInterval(hours: 1))
        _ = Service(color: .systemRed, name: "Ресницы", cost: 1000, duration: TimeInterval(hours: 2, minutes: 30), isArchive: true, additionalServices: [lashes2D, lashes3D, lashes4D])

        let golova = Client(photo: UIImage(named: "golova")!, surname: "Голова", name: "Мария", phonenumber: "79272105059", vk: "https://vk.com/mariyagolova", notes: "Мария Костюшкина", isBlocked: true)
        _ = Client(photo: UIImage(named: "dulikov")!, surname: "Дуликов", name: "Григорий", phonenumber: "79272155559", vk: "", notes: "Ветеренар. Учился в Самарском Государственном Аграрном Университете. Любит кастрировать котов.")
        _ = Client(photo: UIImage(named: "dunyashin")!, surname: "Дуняшин", name: "Егор", vk: "https://vk.com/e.dunyashin", notes: "Староста")
        _ = Client(photo: UIImage(named: "dunyushkin")!, surname: "Дунюшкин", name: "Николай", phonenumber: "79277199264", vk: "https://vk.com/reitars9", notes: "Член клуба любителей Toyota Corolla")
        _ = Client(photo: UIImage(named: "golov")!, surname: "Голов", name: "Максим", phonenumber: "79277004591", vk: "https://vk.com/afterfocus")
        _ = Client(photo: UIImage(named: "holin")!, surname: "Холин", name: "Данил", vk: "https://vk.com/id28793961")
        _ = Client(photo: UIImage(named: "korcev")!, surname: "Корцев", name: "Матвей", phonenumber: "79377938873", vk: "https://vk.com/ytom63")
        let kostyushkina = Client(photo: UIImage(named: "kostyushkina")!, surname: "Костюшкина", name: "Мария", phonenumber: "79370752426", vk: "https://vk.com/id147563704")
        let peshnova = Client(photo: UIImage(named: "peshnova")!, surname: "Пешнова", name: "Елизавета", phonenumber: "79277355555", vk: "https://vk.com/liza.peshnova")
        let trots = Client(photo: UIImage(named: "trots")!, surname: "Троц", name: "Виктория", phonenumber: "79171061906", vk: "https://vk.com/id151942419")
        let fedorova = Client(photo: UIImage(named: "fedorova")!, surname: "Фёдорова", name: "Дарья", phonenumber: "79170391315", vk: "https://vk.com/luckrose")
        _ = Client(photo: nil, surname: "Хван", name: "Кира")
        let egorova = Client(photo: UIImage(named: "egorova")!, surname: "Александровна", name: "Настасья", vk: "https://vk.com/idnastasia16")
        let petrova = Client(photo: UIImage(named: "petrova")!, surname: "Петрова", name: "Ирина", vk: "https://vk.com/id136672421")
        let kirillova = Client(photo: UIImage(named: "kirillova")!, surname: "Кириллова", name: "Екатерина", phonenumber: "79277655010", vk: "https://vk.com/id7772483")
        let ilicheva = Client(photo: UIImage(named: "ilicheva")!, surname: "Ильичёва", name: "Кристина", vk: "https://vk.com/ilichevachris")
        let vechkileva = Client(photo: UIImage(named: "vechkileva")!, surname: "Вечкилёва", name: "Наталья", vk: "https://vk.com/id4739933")
        let boiko = Client(photo: UIImage(named: "boiko")!, surname: "Бойко", name: "Надежда", vk: "https://vk.com/nadezhda.boyko83")
        let melihova = Client(photo: UIImage(named: "melihova")!, surname: "Мелихова", name: "Надежда", vk: "https://vk.com/2h22m")
        let gerasimova = Client(photo: UIImage(named: "gerasimova")!, surname: "Герасимова", name: "Наталья", phonenumber: "79372004373", vk: "https://vk.com/olmeknat")
        let olgina = Client(photo: UIImage(named: "olgina")!, surname: "Ольгина", name: "Ольга", vk: "https://vk.com/id113639246")
        let sergeeva = Client(photo: UIImage(named: "sergeeva")!, surname: "Сергеева", name: "Екатерина", vk: "https://vk.com/id93326504")
        let osipova = Client(photo: UIImage(named: "osipova")!, surname: "Осипова", name: "Яна", vk: "https://vk.com/id58112339")

        // Выходные

        var date = Date(day: 04, month: 11, year: 2018)
        for _ in stride(from: 0, through: 365, by: 7) {
            _ = Weekend(date: date)
            date = Calendar.current.date(byAdding: .day, value: 7, to: date)!
        }

        date = Date(day: 05, month: 11, year: 2018)
        for _ in stride(from: 0, through: 365, by: 7) {
            _ = Weekend(date: date)
            date = Calendar.current.date(byAdding: .day, value: 7, to: date)!
        }

        _ = Weekend(day: 01, month: 01, year: 2019)
        _ = Weekend(day: 02, month: 01, year: 2019)
        _ = Weekend(day: 03, month: 01, year: 2019)

        //  Мария Голова

        _ = Visit(client: golova, dateTime: Date(day: 1, month: 11, year: 2018, hours: 12), service: manicure, cost: 1200, duration: TimeInterval(hours: 3, minutes: 30), additionalServices: [strengthening, withoutDesign])

        _ = Visit(client: golova, dateTime: Date(day: 25, month: 11, year: 2018, hours: 9), service: manicure, cost: 1200, duration: TimeInterval(hours: 3), additionalServices: [strengthening, withoutDesign])

        _ = Visit(client: golova, dateTime: Date(day: 25, month: 11, year: 2018, hours: 12), service: brows, cost: 500, duration: TimeInterval(hours: 1))

        _ = Visit(client: golova, dateTime: Date(day: 17, month: 12, year: 2018, hours: 12), service: manicure, cost: 1400, duration: TimeInterval(hours: 3), additionalServices: [withoutDesign])

        _ = Visit(client: golova, dateTime: Date(day: 10, month: 1, year: 2019, hours: 9), service: manicure, cost: 1600, duration: TimeInterval(hours: 3), additionalServices: [strengthening, withoutDesign])

        _ = Visit(client: golova, dateTime: Date(day: 12, month: 2, year: 2019, hours: 12), service: manicure, cost: 1500, duration: TimeInterval(hours: 4), additionalServices: [nailExtension])

        _ = Visit(client: golova, dateTime: Date(day: 20, month: 2, year: 2019, hours: 9), service: manicure, cost: 1400, duration: TimeInterval(hours: 3), additionalServices: [withoutDesign])

        _ = Visit(client: golova, dateTime: Date(day: 20, month: 2, year: 2019, hours: 12), service: brows, cost: 700, duration: TimeInterval(hours: 1))

        _ = Visit(client: golova, dateTime: Date(day: 7, month: 3, year: 2019, hours: 12), service: manicure, cost: 1500, duration: TimeInterval(hours: 4), additionalServices: [nailExtension], isClientNotCome: true)

        _ = Visit(client: golova, dateTime: Date(day: 20, month: 3, year: 2019, hours: 9), service: manicure, cost: 1400, duration: TimeInterval(hours: 3), additionalServices: [withoutDesign])

        _ = Visit(client: golova, dateTime: Date(day: 20, month: 3, year: 2019, hours: 12), service: brows, cost: 700, duration: TimeInterval(hours: 1))

        _ = Visit(client: golova, dateTime: Date(day: 18, month: 04, year: 2019, hours: 10), service: manicure, cost: 1500, duration: TimeInterval(hours: 4), additionalServices: [strengthening])

        _ = Visit(client: golova, dateTime: Date(day: 18, month: 04, year: 2019, hours: 9), service: brows, cost: 500, duration: TimeInterval(hours: 1))

        //  Мария Костюшкина

        _ = Visit(client: kostyushkina, dateTime: Date(day: 02, month: 11, year: 2018, hours: 19), service: manicure, cost: 1100, duration: TimeInterval(hours: 3))

        _ = Visit(client: kostyushkina, dateTime: Date(day: 1, month: 11, year: 2018, hours: 18), service: manicure, cost: 1300, duration: TimeInterval(hours: 3), additionalServices: [strengthening, withoutDesign])

        _ = Visit(client: kostyushkina, dateTime: Date(day: 22, month: 11, year: 2018, hours: 18), service: manicure, cost: 1300, duration: TimeInterval(hours: 3), additionalServices: [strengthening, withoutDesign])

        _ = Visit(client: kostyushkina, dateTime: Date(day: 22, month: 11, year: 2018, hours: 21), service: brows, cost: 500, duration: TimeInterval(hours: 1))

        _ = Visit(client: kostyushkina, dateTime: Date(day: 14, month: 12, year: 2018, hours: 12), service: manicure, cost: 1300, duration: TimeInterval(hours: 3), additionalServices: [strengthening, withoutDesign])

        _ = Visit(client: kostyushkina, dateTime: Date(day: 4, month: 1, year: 2019, hours: 15), service: manicure, cost: 1300, duration: TimeInterval(hours: 3), additionalServices: [strengthening, withoutDesign], notes: "Может опоздать\nТелефон сломан")

        _ = Visit(client: kostyushkina, dateTime: Date(day: 2, month: 2, year: 2019, hours: 19), service: manicure, cost: 1300, duration: TimeInterval(hours: 3), additionalServices: [strengthening, nailExtension, withoutDesign, withoutCoating, removal], notes: "Может опоздать")

        _ = Visit(client: kostyushkina, dateTime: Date(day: 8, month: 3, year: 2019, hours: 12), service: manicure, cost: 1300, duration: TimeInterval(hours: 3), additionalServices: [strengthening, withoutDesign], isCancelled: true)

        _ = Visit(client: kostyushkina, dateTime: Date(day: 22, month: 3, year: 2019, hours: 9), service: manicure, cost: 1300, duration: TimeInterval(hours: 3), additionalServices: [strengthening, withoutDesign], notes: "Телефон сломан")

        _ = Visit(client: kostyushkina, dateTime: Date(day: 10, month: 04, year: 2019, hours: 18), service: manicure, cost: 1100, duration: TimeInterval(hours: 3), additionalServices: [withoutDesign])

        _ = Visit(client: kostyushkina, dateTime: Date(day: 10, month: 04, year: 2019, hours: 21), service: brows, cost: 500, duration: TimeInterval(hours: 1))

        // Настасья Александровна

        _ = Visit(client: egorova, dateTime: Date(day: 8, month: 11, year: 2018, hours: 12),service: manicure, cost: 1100, duration: TimeInterval(hours: 3), additionalServices: [removal])

        _ = Visit(client: egorova, dateTime: Date(day: 20, month: 11, year: 2018, hours: 9), service: manicure, cost: 1100, duration: TimeInterval(hours: 3), additionalServices: [removal])

        _ = Visit(client: egorova, dateTime: Date(day: 4, month: 12, year: 2018, hours: 12), service: manicure, cost: 1100, duration: TimeInterval(hours: 3), additionalServices: [removal])

        _ = Visit(client: egorova, dateTime: Date(day: 20, month: 12, year: 2018, hours: 9), service: manicure, cost: 1100, duration: TimeInterval(hours: 3), additionalServices: [withoutDesign, removal])

        _ = Visit(client: egorova, dateTime: Date(day: 9, month: 1, year: 2019, hours: 12), service: manicure, cost: 1100, duration: TimeInterval(hours: 3), additionalServices: [removal])

        _ = Visit(client: egorova, dateTime: Date(day: 31, month: 1, year: 2019, hours: 9), service: manicure, cost: 1100, duration: TimeInterval(hours: 3), additionalServices: [withoutDesign, removal])

        _ = Visit(client: egorova, dateTime: Date(day: 14, month: 2, year: 2019, hours: 9), service: manicure, cost: 1100, duration: TimeInterval(hours: 3), additionalServices: [removal])

        _ = Visit(client: egorova, dateTime: Date(day: 27, month: 2, year: 2019, hours: 9), service: manicure, cost: 1100, duration: TimeInterval(hours: 3), additionalServices: [removal])

        _ = Visit(client: egorova, dateTime: Date(day: 12, month: 3, year: 2019, hours: 9), service: manicure, cost: 1100, duration: TimeInterval(hours: 3), additionalServices: [removal])

        _ = Visit(client: egorova, dateTime: Date(day: 26, month: 3, year: 2019, hours: 16), service: manicure, cost: 1100, duration: TimeInterval(hours: 3), additionalServices: [removal])

        // Ирина Петрова

        _ = Visit(client: petrova, dateTime: Date(day: 02, month: 11, year: 2018, hours: 12), service: manicure, cost: 1350, duration: TimeInterval(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: petrova, dateTime: Date(day: 29, month: 11, year: 2018, hours: 12), service: manicure, cost: 1500, duration: TimeInterval(hours: 3), additionalServices: [nailExtension, removal])

        _ = Visit(client: petrova, dateTime: Date(day: 24, month: 11, year: 2018, hours: 12), service: manicure, cost: 1300, duration: TimeInterval(hours: 3, minutes: 30), additionalServices: [strengthening, removal])

        _ = Visit(client: petrova, dateTime: Date(day: 12, month: 12, year: 2018, hours: 12), service: manicure, cost: 1400, duration: TimeInterval(hours: 3, minutes: 30), additionalServices: [strengthening, removal])

        _ = Visit(client: petrova, dateTime: Date(day: 19, month: 1, year: 2019, hours: 15), service: manicure, cost: 1400, duration: TimeInterval(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: petrova, dateTime: Date(day: 16, month: 2, year: 2019, hours: 12), service: manicure, cost: 1400, duration: TimeInterval(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: petrova, dateTime: Date(day: 9, month: 3, year: 2019, hours: 15), service: manicure, cost: 1400, duration: TimeInterval(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: petrova, dateTime: Date(day: 30, month: 3, year: 2019, hours: 12), service: manicure, cost: 1400, duration: TimeInterval(hours: 3), additionalServices: [strengthening, removal])

        // Екатерина Кириллова

        _ = Visit(client: kirillova, dateTime: Date(day: 28, month: 12, year: 2018, hours: 12), service: manicure, cost: 1450, duration: TimeInterval(hours: 3), additionalServices: [removal])

        _ = Visit(client: kirillova, dateTime: Date(day: 8, month: 1, year: 2019, hours: 12), service: manicure, cost: 1400, duration: TimeInterval(hours: 3), additionalServices: [removal])

        _ = Visit(client: kirillova, dateTime: Date(day: 7, month: 2, year: 2019, hours: 12), service: manicure, cost: 1400, duration: TimeInterval(hours: 3), additionalServices: [removal])

        _ = Visit(client: kirillova, dateTime: Date(day: 27, month: 2, year: 2019, hours: 12), service: manicure, cost: 1400, duration: TimeInterval(hours: 3), additionalServices: [removal])

        _ = Visit(client: kirillova, dateTime: Date(day: 8, month: 3, year: 2019, hours: 12), service: manicure, cost: 1400, duration: TimeInterval(hours: 3), additionalServices: [removal])

        _ = Visit(client: kirillova, dateTime: Date(day: 28, month: 3, year: 2019, hours: 9), service: manicure, cost: 1400, duration: TimeInterval(hours: 3), additionalServices: [removal])

        // Кристина Ильичёва

        _ = Visit(client: ilicheva, dateTime: Date(day: 5, month: 12, year: 2018, hours: 19), service: manicure, cost: 1200, duration: TimeInterval(hours: 3), additionalServices: [removal])

        _ = Visit(client: ilicheva, dateTime: Date(day: 27, month: 12, year: 2018, hours: 19), service: manicure, cost: 1200, duration: TimeInterval(hours: 3), additionalServices: [removal])

        _ = Visit(client: ilicheva, dateTime: Date(day: 23, month: 1, year: 2019, hours: 12), service: manicure, cost: 1200, duration: TimeInterval(hours: 3), additionalServices: [removal])

        _ = Visit(client: ilicheva, dateTime: Date(day: 20, month: 2, year: 2019, hours: 13), service: manicure, cost: 1200, duration: TimeInterval(hours: 3), additionalServices: [removal])

        _ = Visit(client: ilicheva, dateTime: Date(day: 20, month: 2, year: 2019, hours: 16), service: brows, cost: 500, duration: TimeInterval(hours: 1))

        _ = Visit(client: ilicheva, dateTime: Date(day: 5, month: 3, year: 2019, hours: 12), service: manicure, cost: 1200, duration: TimeInterval(hours: 3), additionalServices: [removal])

        _ = Visit(client: ilicheva, dateTime: Date(day: 26, month: 3, year: 2019, hours: 12), service: manicure, cost: 1200, duration: TimeInterval(hours: 3), additionalServices: [removal])

        _ = Visit(client: ilicheva, dateTime: Date(day: 26, month: 3, year: 2019, hours: 15), service: brows, cost: 500, duration: TimeInterval(hours: 1))

        // Наталья Вечкилёва

        _ = Visit(client: vechkileva, dateTime: Date(day: 13, month: 11, year: 2018, hours: 19), service: manicure, cost: 1200, duration: TimeInterval(hours: 3), additionalServices: [withoutDesign, removal])

        _ = Visit(client: vechkileva, dateTime: Date(day: 5, month: 12, year: 2018, hours: 16), service: manicure, cost: 1200, duration: TimeInterval(hours: 3), additionalServices: [withoutDesign, removal])

        _ = Visit(client: vechkileva, dateTime: Date(day: 27, month: 12, year: 2018, hours: 16), service: manicure, cost: 1200, duration: TimeInterval(hours: 3), additionalServices: [withoutDesign, removal])

        _ = Visit(client: vechkileva, dateTime: Date(day: 15, month: 1, year: 2019, hours: 19), service: manicure, cost: 1200, duration: TimeInterval(hours: 3), additionalServices: [withoutDesign, removal])

        _ = Visit(client: vechkileva, dateTime: Date(day: 6, month: 2, year: 2019, hours: 19), service: manicure, cost: 1200, duration: TimeInterval(hours: 3), additionalServices: [withoutDesign, removal])

        _ = Visit(client: vechkileva, dateTime: Date(day: 21, month: 2, year: 2019, hours: 17), service: manicure, cost: 1200, duration: TimeInterval(hours: 3), additionalServices: [withoutDesign, removal])

        _ = Visit(client: vechkileva, dateTime: Date(day: 1, month: 3, year: 2019, hours: 19), service: manicure, cost: 1200, duration: TimeInterval(hours: 3), additionalServices: [withoutDesign, removal])

        _ = Visit(client: vechkileva, dateTime: Date(day: 21, month: 3, year: 2019, hours: 17), service: manicure, cost: 1200, duration: TimeInterval(hours: 3), additionalServices: [withoutDesign, removal])

        // Надежда Бойко

        _ = Visit(client: boiko, dateTime: Date(day: 14, month: 11, year: 2018, hours: 9), service: manicure, cost: 1000, duration: TimeInterval(hours: 3), additionalServices: [removal])

        _ = Visit(client: boiko, dateTime: Date(day: 4, month: 12, year: 2018, hours: 9),service: manicure, cost: 1000, duration: TimeInterval(hours: 3), additionalServices: [removal])

        _ = Visit(client: boiko, dateTime: Date(day: 26, month: 12, year: 2018, hours: 9), service: manicure, cost: 1000, duration: TimeInterval(hours: 3), additionalServices: [removal])

        _ = Visit(client: boiko, dateTime: Date(day: 16, month: 1, year: 2019, hours: 9), service: manicure, cost: 1000, duration: TimeInterval(hours: 3), additionalServices: [removal])

        _ = Visit(client: boiko, dateTime: Date(day: 6, month: 2, year: 2019, hours: 9), service: manicure, cost: 1100, duration: TimeInterval(hours: 3), additionalServices: [removal])

        _ = Visit(client: boiko, dateTime: Date(day: 20, month: 2, year: 2019, hours: 20), service: manicure, cost: 50.5, duration: TimeInterval(hours: 1), additionalServices: [withoutCoating], notes: "Только снятие")

        _ = Visit(client: boiko, dateTime: Date(day: 5, month: 3, year: 2019, hours: 9), service: manicure, cost: 1000, duration: TimeInterval(hours: 3), additionalServices: [removal])

        _ = Visit(client: boiko, dateTime: Date(day: 19, month: 3, year: 2019, hours: 9), service: manicure, cost: 1100, duration: TimeInterval(hours: 3), additionalServices: [removal])

        // Надежда Мелихова

        _ = Visit(client: melihova, dateTime: Date(day: 10, month: 11, year: 2018, hours: 9), service: manicure, cost: 1800, duration: TimeInterval(hours: 4), additionalServices: [nailExtension, removal])

        _ = Visit(client: melihova, dateTime: Date(day: 10, month: 11, year: 2018, hours: 13), service: brows, cost: 700, duration: TimeInterval(hours: 1))

        _ = Visit(client: melihova, dateTime: Date(day: 12, month: 12, year: 2018, hours: 18), service: manicure, cost: 1600, duration: TimeInterval(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: melihova, dateTime: Date(day: 12, month: 12, year: 2018, hours: 21), service: brows, cost: 700, duration: TimeInterval(hours: 1))

        _ = Visit(client: melihova, dateTime: Date(day: 29, month: 12, year: 2018, hours: 9), service: manicure, cost: 1800, duration: TimeInterval(hours: 3), additionalServices: [nailExtension, removal])

        _ = Visit(client: melihova, dateTime: Date(day: 29, month: 12, year: 2018, hours: 12), service: brows, cost: 700, duration: TimeInterval(hours: 1))

        _ = Visit(client: melihova, dateTime: Date(day: 26, month: 1, year: 2019, hours: 18), service: manicure, cost: 1600, duration: TimeInterval(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: melihova, dateTime: Date(day: 26, month: 1, year: 2019, hours: 21), service: brows, cost: 700, duration: TimeInterval(hours: 1))

        _ = Visit(client: melihova, dateTime: Date(day: 16, month: 2, year: 2019, hours: 18), service: manicure, cost: 1600, duration: TimeInterval(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: melihova, dateTime: Date(day: 16, month: 2, year: 2019, hours: 21), service: brows, cost: 700, duration: TimeInterval(hours: 1))

        _ = Visit(client: melihova, dateTime: Date(day: 2, month: 3, year: 2019, hours: 18), service: manicure, cost: 1600, duration: TimeInterval(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: melihova, dateTime: Date(day: 2, month: 3, year: 2019, hours: 21), service: brows, cost: 700, duration: TimeInterval(hours: 1))

        _ = Visit(client: melihova, dateTime: Date(day: 23, month: 3, year: 2019, hours: 15), service: manicure, cost: 1600, duration: TimeInterval(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: melihova, dateTime: Date(day: 23, month: 3, year: 2019, hours: 18), service: brows, cost: 700, duration: TimeInterval(hours: 1))

        // Наталья Герасимова

        _ = Visit(client: gerasimova, dateTime: Date(day: 26, month: 11, year: 2018, hours: 12), service: manicure, cost: 1000, duration: TimeInterval(hours: 3), additionalServices: [removal])

        _ = Visit(client: gerasimova, dateTime: Date(day: 16, month: 11, year: 2018, hours: 12), service: manicure, cost: 1000, duration: TimeInterval(hours: 3), additionalServices: [removal])

        _ = Visit(client: gerasimova, dateTime: Date(day: 7, month: 2, year: 2019, hours: 15), service: brows, cost: 500, duration: TimeInterval(hours: 1))

        _ = Visit(client: gerasimova, dateTime: Date(day: 6, month: 12, year: 2018, hours: 12), service: manicure, cost: 1000, duration: TimeInterval(hours: 3), additionalServices: [removal])

        _ = Visit(client: gerasimova, dateTime: Date(day: 29, month: 12, year: 2018, hours: 15), service: manicure, cost: 1100, duration: TimeInterval(hours: 3), additionalServices: [removal])

        _ = Visit(client: gerasimova, dateTime: Date(day: 16, month: 1, year: 2019, hours: 12), service: manicure, cost: 1100, duration: TimeInterval(hours: 3), additionalServices: [removal])

        _ = Visit(client: gerasimova, dateTime: Date(day: 12, month: 2, year: 2019, hours: 16), service: brows, cost: 500, duration: TimeInterval(hours: 1))

        _ = Visit(client: gerasimova, dateTime: Date(day: 8, month: 2, year: 2019, hours: 12), service: manicure, cost: 1100, duration: TimeInterval(hours: 3), additionalServices: [removal])

        _ = Visit(client: gerasimova, dateTime: Date(day: 28, month: 2, year: 2019, hours: 12), service: manicure, cost: 1100, duration: TimeInterval(hours: 3), additionalServices: [removal], isCancelled: true)

        _ = Visit(client: gerasimova, dateTime: Date(day: 12, month: 3, year: 2019, hours: 12), service: manicure, cost: 1100, duration: TimeInterval(hours: 3), additionalServices: [removal])

        _ = Visit(client: gerasimova, dateTime: Date(day: 15, month: 3, year: 2019, hours: 12), service: brows, cost: 500, duration: TimeInterval(hours: 1))

        _ = Visit(client: gerasimova, dateTime: Date(day: 29, month: 3, year: 2019, hours: 12), service: manicure, cost: 1100, duration: TimeInterval(hours: 3), additionalServices: [removal])

        // Ольга Ольгина

        _ = Visit(client: olgina, dateTime: Date(day: 8, month: 11, year: 2018, hours: 9), service: manicure, cost: 1300, duration: TimeInterval(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: olgina, dateTime: Date(day: 21, month: 11, year: 2018, hours: 9), service: manicure, cost: 1300, duration: TimeInterval(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: olgina, dateTime: Date(day: 7, month: 12, year: 2018, hours: 9), service: manicure, cost: 1300, duration: TimeInterval(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: olgina, dateTime: Date(day: 26, month: 12, year: 2018, hours: 12), service: manicure, cost: 1300, duration: TimeInterval(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: olgina, dateTime: Date(day: 17, month: 1, year: 2019, hours: 9), service: manicure, cost: 1300, duration: TimeInterval(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: olgina, dateTime: Date(day: 1, month: 2, year: 2019, hours: 9), service: manicure, cost: 1300, duration: TimeInterval(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: olgina, dateTime: Date(day: 14, month: 2, year: 2019, hours: 12), service: manicure, cost: 1300, duration: TimeInterval(hours: 3), additionalServices: [strengthening, removal], isClientNotCome: true)

        _ = Visit(client: olgina, dateTime: Date(day: 15, month: 3, year: 2019, hours: 9), service: manicure, cost: 1300, duration: TimeInterval(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: olgina, dateTime: Date(day: 28, month: 3, year: 2019, hours: 12), service: manicure, cost: 1300, duration: TimeInterval(hours: 3), additionalServices: [strengthening, removal])

        // Елизавета Пешнова

        _ = Visit(client: peshnova, dateTime: Date(day: 5, month: 2, year: 2019, hours: 19), service: manicure, cost: 1800, duration: TimeInterval(hours: 4), additionalServices: [nailExtension, removal])

        _ = Visit(client: peshnova, dateTime: Date(day: 9, month: 2, year: 2019, hours: 12), service: brows, cost: 700, duration: TimeInterval(hours: 1))

        _ = Visit(client: peshnova, dateTime: Date(day: 19, month: 2, year: 2019, hours: 19), service: manicure, cost: 1800, duration: TimeInterval(hours: 4), additionalServices: [nailExtension, removal])

        _ = Visit(client: peshnova, dateTime: Date(day: 28, month: 2, year: 2019, hours: 12), service: brows, cost: 700, duration: TimeInterval(hours: 1))

        _ = Visit(client: peshnova, dateTime: Date(day: 5, month: 3, year: 2019, hours: 19), service: manicure, cost: 1800, duration: TimeInterval(hours: 4), additionalServices: [nailExtension, removal])

        _ = Visit(client: peshnova, dateTime: Date(day: 6, month: 3, year: 2019, hours: 12), service: brows, cost: 700, duration: TimeInterval(hours: 1))

        _ = Visit(client: peshnova, dateTime: Date(day: 14, month: 3, year: 2019, hours: 18), service: manicure, cost: 1800, duration: TimeInterval(hours: 4), additionalServices: [nailExtension, removal])

        _ = Visit(client: peshnova, dateTime: Date(day: 29, month: 3, year: 2019, hours: 15), service: manicure, cost: 1800, duration: TimeInterval(hours: 4), additionalServices: [nailExtension, removal])

        _ = Visit(client: peshnova, dateTime: Date(day: 29, month: 3, year: 2019, hours: 19), service: brows, cost: 700, duration: TimeInterval(hours: 1))

        // Виктория Троц

        _ = Visit(client: trots, dateTime: Date(day: 7, month: 2, year: 2019, hours: 9), service: manicure, cost: 1600, duration: TimeInterval(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: trots, dateTime: Date(day: 26, month: 2, year: 2019, hours: 9), service: manicure, cost: 1600, duration: TimeInterval(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: trots, dateTime: Date(day: 14, month: 3, year: 2019, hours: 9), service: manicure, cost: 1600, duration: TimeInterval(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: trots, dateTime: Date(day: 26, month: 3, year: 2019, hours: 19), service: manicure, cost: 1600, duration: TimeInterval(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: trots, dateTime: Date(day: 7, month: 2, year: 2019, hours: 19), service: manicure, cost: 1600, duration: TimeInterval(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: trots, dateTime: Date(day: 28, month: 2, year: 2019, hours: 9), service: manicure, cost: 1600, duration: TimeInterval(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: trots, dateTime: Date(day: 6, month: 3, year: 2019, hours: 9), service: manicure, cost: 1600, duration: TimeInterval(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: trots, dateTime: Date(day: 22, month: 3, year: 2019, hours: 12), service: manicure, cost: 1600, duration: TimeInterval(hours: 3), additionalServices: [strengthening, removal])

        // Екатерина Сергеева

        _ = Visit(client: sergeeva, dateTime: Date(day: 5, month: 2, year: 2019, hours: 9), service: manicure, cost: 1200, duration: TimeInterval(hours: 3), additionalServices: [withoutDesign, removal])

        _ = Visit(client: sergeeva, dateTime: Date(day: 22, month: 2, year: 2019, hours: 9), service: manicure, cost: 1200, duration: TimeInterval(hours: 3), additionalServices: [withoutDesign, removal])

        _ = Visit(client: sergeeva, dateTime: Date(day: 7, month: 3, year: 2019, hours: 9), service: manicure, cost: 1200, duration: TimeInterval(hours: 3), additionalServices: [withoutDesign, removal])

        _ = Visit(client: sergeeva, dateTime: Date(day: 30, month: 3, year: 2019, hours: 9), service: manicure, cost: 1200, duration: TimeInterval(hours: 3), additionalServices: [withoutDesign, removal])

        // Яна Осипова

        _ = Visit(client: osipova, dateTime: Date(day: 22, month: 1, year: 2019, hours: 9), service: manicure, cost: 1400, duration: TimeInterval(hours: 3), additionalServices: [removal])

        _ = Visit(client: osipova, dateTime: Date(day: 13, month: 2, year: 2019, hours: 9), service: manicure, cost: 1400, duration: TimeInterval(hours: 3), additionalServices: [removal])

        _ = Visit(client: osipova, dateTime: Date(day: 13, month: 2, year: 2019, hours: 12), service: brows, cost: 700, duration: TimeInterval(hours: 1))

        _ = Visit(client: osipova, dateTime: Date(day: 1, month: 3, year: 2019, hours: 9), service: manicure, cost: 1400, duration: TimeInterval(hours: 3), additionalServices: [removal])

        _ = Visit(client: osipova, dateTime: Date(day: 1, month: 3, year: 2019, hours: 12), service: brows, cost: 700, duration: TimeInterval(hours: 1))

        _ = Visit(client: osipova, dateTime: Date(day: 13, month: 3, year: 2019, hours: 9), service: manicure, cost: 1400, duration: TimeInterval(hours: 3), additionalServices: [removal])

        _ = Visit(client: osipova, dateTime: Date(day: 13, month: 3, year: 2019, hours: 12), service: brows, cost: 700, duration: TimeInterval(hours: 1))

        _ = Visit(client: osipova, dateTime: Date(day: 26, month: 3, year: 2019, hours: 9), service: manicure, cost: 1400, duration: TimeInterval(hours: 3), additionalServices: [removal])

        _ = Visit(client: osipova, dateTime: Date(day: 29, month: 3, year: 2019, hours: 20), service: brows, cost: 700, duration: TimeInterval(hours: 1))

        // Дарья Фёдорова

        _ = Visit(client: fedorova, dateTime: Date(day: 30, month: 1, year: 2019, hours: 9), service: manicure, cost: 1600, duration: TimeInterval(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: fedorova, dateTime: Date(day: 13, month: 2, year: 2019, hours: 13), service: manicure, cost: 1600, duration: TimeInterval(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: fedorova, dateTime: Date(day: 21, month: 2, year: 2019, hours: 9), service: manicure, cost: 1600, duration: TimeInterval(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: fedorova, dateTime: Date(day: 6, month: 3, year: 2019, hours: 13), service: manicure, cost: 1600, duration: TimeInterval(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: fedorova, dateTime: Date(day: 27, month: 3, year: 2019, hours: 12), service: manicure, cost: 1600, duration: TimeInterval(hours: 3), additionalServices: [strengthening, removal])
    }
}
