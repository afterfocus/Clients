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
    1. Убрать собственную реализацию Date. Использовать Foundation.Date.
    2. Переработать "репозитории"
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
            let visit = VisitRepository.visit(with: urlComponents!.queryItems!.first!.value!)!

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
        let strengthening = AdditionalService(name: "Укрепление", cost: 200, duration: Time())
        let nailExtension = AdditionalService(name: "Наращивание", cost: 400, duration: Time(hours: 1))
        let withoutDesign = AdditionalService(name: "Без дизайна", cost: -200, duration: Time(minutes: -30))
        let removal = AdditionalService(name: "Снятие", cost: 50, duration: Time())
        let withoutCoating = AdditionalService(name: "Без покрытия", cost: -900, duration: Time(hours: -1, minutes: -30))
        let lashes2D = AdditionalService(name: "2D", cost: 200, duration: Time())
        let lashes3D = AdditionalService(name: "3D", cost: 400, duration: Time(hours: 1))
        let lashes4D = AdditionalService(name: "4D", cost: 600, duration: Time(hours: 2))

        let manicure = Service(colorId: UIColor.blue.id, name: "Маникюр", cost: 1400, duration: Time(hours: 3), additionalServices: [strengthening, nailExtension, withoutDesign, removal, withoutCoating])
        let brows = Service(colorId: UIColor.green.id, name: "Брови", cost: 700, duration: Time(hours: 1))
        _ = Service(colorId: UIColor.red.id, name: "Ресницы", cost: 1000, duration: Time(hours: 2, minutes: 30), isArchive: true, additionalServices: [lashes2D, lashes3D, lashes4D])

        let golova = Client(photoData: UIImage(named: "golova")?.jpegData(compressionQuality: 1.0), surname: "Голова", name: "Мария", phonenumber: "79272105059", vk: "https://vk.com/mariyagolova", notes: "Мария Костюшкина", isBlocked: true)
        _ = Client(photoData: UIImage(named: "dulikov")?.jpegData(compressionQuality: 1.0), surname: "Дуликов", name: "Григорий", phonenumber: "79272155559", vk: "", notes: "Ветеренар. Учился в Самарском Государственном Аграрном Университете. Любит кастрировать котов.")
        _ = Client(photoData: UIImage(named: "dunyashin")?.jpegData(compressionQuality: 1.0), surname: "Дуняшин", name: "Егор", vk: "https://vk.com/e.dunyashin", notes: "Староста")
        _ = Client(photoData: UIImage(named: "dunyushkin")?.jpegData(compressionQuality: 1.0), surname: "Дунюшкин", name: "Николай", phonenumber: "79277199264", vk: "https://vk.com/reitars9", notes: "Член клуба любителей Toyota Corolla")
        _ = Client(photoData: UIImage(named: "golov")?.jpegData(compressionQuality: 1.0), surname: "Голов", name: "Максим", phonenumber: "79277004591", vk: "https://vk.com/afterfocus")
        _ = Client(photoData: UIImage(named: "holin")?.jpegData(compressionQuality: 1.0), surname: "Холин", name: "Данил", vk: "https://vk.com/id28793961")
        _ = Client(photoData: UIImage(named: "korcev")?.jpegData(compressionQuality: 1.0), surname: "Корцев", name: "Матвей", phonenumber: "79377938873", vk: "https://vk.com/ytom63")
        let kostyushkina = Client(photoData: UIImage(named: "kostyushkina")?.jpegData(compressionQuality: 1.0), surname: "Костюшкина", name: "Мария", phonenumber: "79370752426", vk: "https://vk.com/id147563704")
        let peshnova = Client(photoData: UIImage(named: "peshnova")?.jpegData(compressionQuality: 1.0), surname: "Пешнова", name: "Елизавета", phonenumber: "79277355555", vk: "https://vk.com/liza.peshnova")
        let trots = Client(photoData: UIImage(named: "trots")?.jpegData(compressionQuality: 1.0), surname: "Троц", name: "Виктория", phonenumber: "79171061906", vk: "https://vk.com/id151942419")
        let fedorova = Client(photoData: UIImage(named: "fedorova")?.jpegData(compressionQuality: 1.0), surname: "Фёдорова", name: "Дарья", phonenumber: "79170391315", vk: "https://vk.com/luckrose")
        _ = Client(photoData: nil, surname: "Хван", name: "Кира")
        let egorova = Client(photoData: UIImage(named: "egorova")?.jpegData(compressionQuality: 1.0), surname: "Александровна", name: "Настасья", vk: "https://vk.com/idnastasia16")
        let petrova = Client(photoData: UIImage(named: "petrova")?.jpegData(compressionQuality: 1.0), surname: "Петрова", name: "Ирина", vk: "https://vk.com/id136672421")
        let kirillova = Client(photoData: UIImage(named: "kirillova")?.jpegData(compressionQuality: 1.0), surname: "Кириллова", name: "Екатерина", phonenumber: "79277655010", vk: "https://vk.com/id7772483")
        let ilicheva = Client(photoData: UIImage(named: "ilicheva")?.jpegData(compressionQuality: 1.0), surname: "Ильичёва", name: "Кристина", vk: "https://vk.com/ilichevachris")
        let vechkileva = Client(photoData: UIImage(named: "vechkileva")?.jpegData(compressionQuality: 1.0), surname: "Вечкилёва", name: "Наталья", vk: "https://vk.com/id4739933")
        let boiko = Client(photoData: UIImage(named: "boiko")?.jpegData(compressionQuality: 1.0), surname: "Бойко", name: "Надежда", vk: "https://vk.com/nadezhda.boyko83")
        let melihova = Client(photoData: UIImage(named: "melihova")?.jpegData(compressionQuality: 1.0), surname: "Мелихова", name: "Надежда", vk: "https://vk.com/2h22m")
        let gerasimova = Client(photoData: UIImage(named: "gerasimova")?.jpegData(compressionQuality: 1.0), surname: "Герасимова", name: "Наталья", phonenumber: "79372004373", vk: "https://vk.com/olmeknat")
        let olgina = Client(photoData: UIImage(named: "olgina")?.jpegData(compressionQuality: 1.0), surname: "Ольгина", name: "Ольга", vk: "https://vk.com/id113639246")
        let sergeeva = Client(photoData: UIImage(named: "sergeeva")?.jpegData(compressionQuality: 1.0), surname: "Сергеева", name: "Екатерина", vk: "https://vk.com/id93326504")
        let osipova = Client(photoData: UIImage(named: "osipova")?.jpegData(compressionQuality: 1.0), surname: "Осипова", name: "Яна", vk: "https://vk.com/id58112339")

        // Выходные

        var date = Date(day: 04, month: 11, year: 2018)
        for _ in stride(from: 0, through: 365, by: 7) {
            _ = Weekend(date: date)
            date += 7
        }

        date = Date(day: 05, month: 11, year: 2018)
        for _ in stride(from: 0, through: 365, by: 7) {
            _ = Weekend(date: date)
            date += 7
        }

        _ = Weekend(day: 01, month: 01, year: 2019)
        _ = Weekend(day: 02, month: 01, year: 2019)
        _ = Weekend(day: 03, month: 01, year: 2019)

        //  Мария Голова

        _ = Visit(client: golova, date: Date(day: 1, month: 11, year: 2018), time: Time(hours: 12), service: manicure, cost: 1200, duration: Time(hours: 3, minutes: 30), additionalServices: [strengthening, withoutDesign])

        _ = Visit(client: golova, date: Date(day: 25, month: 11, year: 2018), time: Time(hours: 9), service: manicure, cost: 1200, duration: Time(hours: 3), additionalServices: [strengthening, withoutDesign])

        _ = Visit(client: golova, date: Date(day: 25, month: 11, year: 2018), time: Time(hours: 12), service: brows, cost: 500, duration: Time(hours: 1))

        _ = Visit(client: golova, date: Date(day: 17, month: 12, year: 2018), time: Time(hours: 12), service: manicure, cost: 1400, duration: Time(hours: 3), additionalServices: [withoutDesign])

        _ = Visit(client: golova, date: Date(day: 10, month: 1, year: 2019), time: Time(hours: 9), service: manicure, cost: 1600, duration: Time(hours: 3), additionalServices: [strengthening, withoutDesign])

        _ = Visit(client: golova, date: Date(day: 12, month: 2, year: 2019), time: Time(hours: 12), service: manicure, cost: 1500, duration: Time(hours: 4), additionalServices: [nailExtension])

        _ = Visit(client: golova, date: Date(day: 20, month: 2, year: 2019), time: Time(hours: 9), service: manicure, cost: 1400, duration: Time(hours: 3), additionalServices: [withoutDesign])

        _ = Visit(client: golova, date: Date(day: 20, month: 2, year: 2019), time: Time(hours: 12), service: brows, cost: 700, duration: Time(hours: 1))

        _ = Visit(client: golova, date: Date(day: 7, month: 3, year: 2019), time: Time(hours: 12), service: manicure, cost: 1500, duration: Time(hours: 4), additionalServices: [nailExtension], isClientNotCome: true)

        _ = Visit(client: golova, date: Date(day: 20, month: 3, year: 2019), time: Time(hours: 9), service: manicure, cost: 1400, duration: Time(hours: 3), additionalServices: [withoutDesign])

        _ = Visit(client: golova, date: Date(day: 20, month: 3, year: 2019), time: Time(hours: 12), service: brows, cost: 700, duration: Time(hours: 1))

        _ = Visit(client: golova, date: Date(day: 18, month: 04, year: 2019), time: Time(hours: 10), service: manicure, cost: 1500, duration: Time(hours: 4), additionalServices: [strengthening])

        _ = Visit(client: golova, date: Date(day: 18, month: 04, year: 2019), time: Time(hours: 9), service: brows, cost: 500, duration: Time(hours: 1))

        //  Мария Костюшкина

        _ = Visit(client: kostyushkina, date: Date(day: 02, month: 11, year: 2018), time: Time(hours: 19), service: manicure, cost: 1100, duration: Time(hours: 3))

        _ = Visit(client: kostyushkina, date: Date(day: 1, month: 11, year: 2018), time: Time(hours: 18), service: manicure, cost: 1300, duration: Time(hours: 3), additionalServices: [strengthening, withoutDesign])

        _ = Visit(client: kostyushkina, date: Date(day: 22, month: 11, year: 2018), time: Time(hours: 18), service: manicure, cost: 1300, duration: Time(hours: 3), additionalServices: [strengthening, withoutDesign])

        _ = Visit(client: kostyushkina, date: Date(day: 22, month: 11, year: 2018), time: Time(hours: 21), service: brows, cost: 500, duration: Time(hours: 1))

        _ = Visit(client: kostyushkina, date: Date(day: 14, month: 12, year: 2018), time: Time(hours: 12), service: manicure, cost: 1300, duration: Time(hours: 3), additionalServices: [strengthening, withoutDesign])

        _ = Visit(client: kostyushkina, date: Date(day: 4, month: 1, year: 2019), time: Time(hours: 15), service: manicure, cost: 1300, duration: Time(hours: 3), additionalServices: [strengthening, withoutDesign], notes: "Может опоздать\nТелефон сломан")

        _ = Visit(client: kostyushkina, date: Date(day: 2, month: 2, year: 2019), time: Time(hours: 19), service: manicure, cost: 1300, duration: Time(hours: 3), additionalServices: [strengthening, nailExtension, withoutDesign, withoutCoating, removal], notes: "Может опоздать")

        _ = Visit(client: kostyushkina, date: Date(day: 8, month: 3, year: 2019), time: Time(hours: 12), service: manicure, cost: 1300, duration: Time(hours: 3), additionalServices: [strengthening, withoutDesign], isCancelled: true)

        _ = Visit(client: kostyushkina, date: Date(day: 22, month: 3, year: 2019), time: Time(hours: 9), service: manicure, cost: 1300, duration: Time(hours: 3), additionalServices: [strengthening, withoutDesign], notes: "Телефон сломан")

        _ = Visit(client: kostyushkina, date: Date(day: 10, month: 04, year: 2019), time: Time(hours: 18), service: manicure, cost: 1100, duration: Time(hours: 3), additionalServices: [withoutDesign])

        _ = Visit(client: kostyushkina, date: Date(day: 10, month: 04, year: 2019), time: Time(hours: 21), service: brows, cost: 500, duration: Time(hours: 1))

        // Настасья Александровна

        _ = Visit(client: egorova, date: Date(day: 8, month: 11, year: 2018), time: Time(hours: 12),service: manicure, cost: 1100, duration: Time(hours: 3), additionalServices: [removal])

        _ = Visit(client: egorova, date: Date(day: 20, month: 11, year: 2018), time: Time(hours: 9), service: manicure, cost: 1100, duration: Time(hours: 3), additionalServices: [removal])

        _ = Visit(client: egorova, date: Date(day: 4, month: 12, year: 2018), time: Time(hours: 12), service: manicure, cost: 1100, duration: Time(hours: 3), additionalServices: [removal])

        _ = Visit(client: egorova, date: Date(day: 20, month: 12, year: 2018), time: Time(hours: 9), service: manicure, cost: 1100, duration: Time(hours: 3), additionalServices: [withoutDesign, removal])

        _ = Visit(client: egorova, date: Date(day: 9, month: 1, year: 2019), time: Time(hours: 12), service: manicure, cost: 1100, duration: Time(hours: 3), additionalServices: [removal])

        _ = Visit(client: egorova, date: Date(day: 31, month: 1, year: 2019), time: Time(hours: 9), service: manicure, cost: 1100, duration: Time(hours: 3), additionalServices: [withoutDesign, removal])

        _ = Visit(client: egorova, date: Date(day: 14, month: 2, year: 2019), time: Time(hours: 9), service: manicure, cost: 1100, duration: Time(hours: 3), additionalServices: [removal])

        _ = Visit(client: egorova, date: Date(day: 27, month: 2, year: 2019), time: Time(hours: 9), service: manicure, cost: 1100, duration: Time(hours: 3), additionalServices: [removal])

        _ = Visit(client: egorova, date: Date(day: 12, month: 3, year: 2019), time: Time(hours: 9), service: manicure, cost: 1100, duration: Time(hours: 3), additionalServices: [removal])

        _ = Visit(client: egorova, date: Date(day: 26, month: 3, year: 2019), time: Time(hours: 16), service: manicure, cost: 1100, duration: Time(hours: 3), additionalServices: [removal])

        // Ирина Петрова

        _ = Visit(client: petrova, date: Date(day: 02, month: 11, year: 2018), time: Time(hours: 12), service: manicure, cost: 1350, duration: Time(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: petrova, date: Date(day: 29, month: 11, year: 2018), time: Time(hours: 12), service: manicure, cost: 1500, duration: Time(hours: 3), additionalServices: [nailExtension, removal])

        _ = Visit(client: petrova, date: Date(day: 24, month: 11, year: 2018), time: Time(hours: 12), service: manicure, cost: 1300, duration: Time(hours: 3, minutes: 30), additionalServices: [strengthening, removal])

        _ = Visit(client: petrova, date: Date(day: 12, month: 12, year: 2018), time: Time(hours: 12), service: manicure, cost: 1400, duration: Time(hours: 3, minutes: 30), additionalServices: [strengthening, removal])

        _ = Visit(client: petrova, date: Date(day: 19, month: 1, year: 2019), time: Time(hours: 15), service: manicure, cost: 1400, duration: Time(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: petrova, date: Date(day: 16, month: 2, year: 2019), time: Time(hours: 12), service: manicure, cost: 1400, duration: Time(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: petrova, date: Date(day: 9, month: 3, year: 2019), time: Time(hours: 15), service: manicure, cost: 1400, duration: Time(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: petrova, date: Date(day: 30, month: 3, year: 2019), time: Time(hours: 12), service: manicure, cost: 1400, duration: Time(hours: 3), additionalServices: [strengthening, removal])

        // Екатерина Кириллова

        _ = Visit(client: kirillova, date: Date(day: 28, month: 12, year: 2018), time: Time(hours: 12), service: manicure, cost: 1450, duration: Time(hours: 3), additionalServices: [removal])

        _ = Visit(client: kirillova, date: Date(day: 8, month: 1, year: 2019), time: Time(hours: 12), service: manicure, cost: 1400, duration: Time(hours: 3), additionalServices: [removal])

        _ = Visit(client: kirillova, date: Date(day: 7, month: 2, year: 2019), time: Time(hours: 12), service: manicure, cost: 1400, duration: Time(hours: 3), additionalServices: [removal])

        _ = Visit(client: kirillova, date: Date(day: 27, month: 2, year: 2019), time: Time(hours: 12), service: manicure, cost: 1400, duration: Time(hours: 3), additionalServices: [removal])

        _ = Visit(client: kirillova, date: Date(day: 8, month: 3, year: 2019), time: Time(hours: 12), service: manicure, cost: 1400, duration: Time(hours: 3), additionalServices: [removal])

        _ = Visit(client: kirillova, date: Date(day: 28, month: 3, year: 2019), time: Time(hours: 9), service: manicure, cost: 1400, duration: Time(hours: 3), additionalServices: [removal])

        // Кристина Ильичёва

        _ = Visit(client: ilicheva, date: Date(day: 5, month: 12, year: 2018), time: Time(hours: 19), service: manicure, cost: 1200, duration: Time(hours: 3), additionalServices: [removal])

        _ = Visit(client: ilicheva, date: Date(day: 27, month: 12, year: 2018), time: Time(hours: 19), service: manicure, cost: 1200, duration: Time(hours: 3), additionalServices: [removal])

        _ = Visit(client: ilicheva, date: Date(day: 23, month: 1, year: 2019), time: Time(hours: 12), service: manicure, cost: 1200, duration: Time(hours: 3), additionalServices: [removal])

        _ = Visit(client: ilicheva, date: Date(day: 20, month: 2, year: 2019), time: Time(hours: 13), service: manicure, cost: 1200, duration: Time(hours: 3), additionalServices: [removal])

        _ = Visit(client: ilicheva, date: Date(day: 20, month: 2, year: 2019), time: Time(hours: 16), service: brows, cost: 500, duration: Time(hours: 1))

        _ = Visit(client: ilicheva, date: Date(day: 5, month: 3, year: 2019), time: Time(hours: 12), service: manicure, cost: 1200, duration: Time(hours: 3), additionalServices: [removal])

        _ = Visit(client: ilicheva, date: Date(day: 26, month: 3, year: 2019), time: Time(hours: 12), service: manicure, cost: 1200, duration: Time(hours: 3), additionalServices: [removal])

        _ = Visit(client: ilicheva, date: Date(day: 26, month: 3, year: 2019), time: Time(hours: 15), service: brows, cost: 500, duration: Time(hours: 1))

        // Наталья Вечкилёва

        _ = Visit(client: vechkileva, date: Date(day: 13, month: 11, year: 2018), time: Time(hours: 19), service: manicure, cost: 1200, duration: Time(hours: 3), additionalServices: [withoutDesign, removal])

        _ = Visit(client: vechkileva, date: Date(day: 5, month: 12, year: 2018), time: Time(hours: 16), service: manicure, cost: 1200, duration: Time(hours: 3), additionalServices: [withoutDesign, removal])

        _ = Visit(client: vechkileva, date: Date(day: 27, month: 12, year: 2018), time: Time(hours: 16), service: manicure, cost: 1200, duration: Time(hours: 3), additionalServices: [withoutDesign, removal])

        _ = Visit(client: vechkileva, date: Date(day: 15, month: 1, year: 2019), time: Time(hours: 19), service: manicure, cost: 1200, duration: Time(hours: 3), additionalServices: [withoutDesign, removal])

        _ = Visit(client: vechkileva, date: Date(day: 6, month: 2, year: 2019), time: Time(hours: 19), service: manicure, cost: 1200, duration: Time(hours: 3), additionalServices: [withoutDesign, removal])

        _ = Visit(client: vechkileva, date: Date(day: 21, month: 2, year: 2019), time: Time(hours: 17), service: manicure, cost: 1200, duration: Time(hours: 3), additionalServices: [withoutDesign, removal])

        _ = Visit(client: vechkileva, date: Date(day: 1, month: 3, year: 2019), time: Time(hours: 19), service: manicure, cost: 1200, duration: Time(hours: 3), additionalServices: [withoutDesign, removal])

        _ = Visit(client: vechkileva, date: Date(day: 21, month: 3, year: 2019), time: Time(hours: 17), service: manicure, cost: 1200, duration: Time(hours: 3), additionalServices: [withoutDesign, removal])

        // Надежда Бойко

        _ = Visit(client: boiko, date: Date(day: 14, month: 11, year: 2018), time: Time(hours: 9), service: manicure, cost: 1000, duration: Time(hours: 3), additionalServices: [removal])

        _ = Visit(client: boiko, date: Date(day: 4, month: 12, year: 2018), time: Time(hours: 9),service: manicure, cost: 1000, duration: Time(hours: 3), additionalServices: [removal])

        _ = Visit(client: boiko, date: Date(day: 26, month: 12, year: 2018), time: Time(hours: 9), service: manicure, cost: 1000, duration: Time(hours: 3), additionalServices: [removal])

        _ = Visit(client: boiko, date: Date(day: 16, month: 1, year: 2019), time: Time(hours: 9), service: manicure, cost: 1000, duration: Time(hours: 3), additionalServices: [removal])

        _ = Visit(client: boiko, date: Date(day: 6, month: 2, year: 2019), time: Time(hours: 9), service: manicure, cost: 1100, duration: Time(hours: 3), additionalServices: [removal])

        _ = Visit(client: boiko, date: Date(day: 20, month: 2, year: 2019), time: Time(hours: 20), service: manicure, cost: 50.5, duration: Time(hours: 1), additionalServices: [withoutCoating], notes: "Только снятие")

        _ = Visit(client: boiko, date: Date(day: 5, month: 3, year: 2019), time: Time(hours: 9), service: manicure, cost: 1000, duration: Time(hours: 3), additionalServices: [removal])

        _ = Visit(client: boiko, date: Date(day: 19, month: 3, year: 2019), time: Time(hours: 9), service: manicure, cost: 1100, duration: Time(hours: 3), additionalServices: [removal])

        // Надежда Мелихова

        _ = Visit(client: melihova, date: Date(day: 10, month: 11, year: 2018), time: Time(hours: 9), service: manicure, cost: 1800, duration: Time(hours: 4), additionalServices: [nailExtension, removal])

        _ = Visit(client: melihova, date: Date(day: 10, month: 11, year: 2018), time: Time(hours: 13), service: brows, cost: 700, duration: Time(hours: 1))

        _ = Visit(client: melihova, date: Date(day: 12, month: 12, year: 2018), time: Time(hours: 18), service: manicure, cost: 1600, duration: Time(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: melihova, date: Date(day: 12, month: 12, year: 2018), time: Time(hours: 21), service: brows, cost: 700, duration: Time(hours: 1))

        _ = Visit(client: melihova, date: Date(day: 29, month: 12, year: 2018), time: Time(hours: 9), service: manicure, cost: 1800, duration: Time(hours: 3), additionalServices: [nailExtension, removal])

        _ = Visit(client: melihova, date: Date(day: 29, month: 12, year: 2018), time: Time(hours: 12), service: brows, cost: 700, duration: Time(hours: 1))

        _ = Visit(client: melihova, date: Date(day: 26, month: 1, year: 2019), time: Time(hours: 18), service: manicure, cost: 1600, duration: Time(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: melihova, date: Date(day: 26, month: 1, year: 2019), time: Time(hours: 21), service: brows, cost: 700, duration: Time(hours: 1))

        _ = Visit(client: melihova, date: Date(day: 16, month: 2, year: 2019), time: Time(hours: 18), service: manicure, cost: 1600, duration: Time(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: melihova, date: Date(day: 16, month: 2, year: 2019), time: Time(hours: 21), service: brows, cost: 700, duration: Time(hours: 1))

        _ = Visit(client: melihova, date: Date(day: 2, month: 3, year: 2019), time: Time(hours: 18), service: manicure, cost: 1600, duration: Time(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: melihova, date: Date(day: 2, month: 3, year: 2019), time: Time(hours: 21), service: brows, cost: 700, duration: Time(hours: 1))

        _ = Visit(client: melihova, date: Date(day: 23, month: 3, year: 2019), time: Time(hours: 15), service: manicure, cost: 1600, duration: Time(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: melihova, date: Date(day: 23, month: 3, year: 2019), time: Time(hours: 18), service: brows, cost: 700, duration: Time(hours: 1))

        // Наталья Герасимова

        _ = Visit(client: gerasimova, date: Date(day: 26, month: 11, year: 2018), time: Time(hours: 12), service: manicure, cost: 1000, duration: Time(hours: 3), additionalServices: [removal])

        _ = Visit(client: gerasimova, date: Date(day: 16, month: 11, year: 2018), time: Time(hours: 12), service: manicure, cost: 1000, duration: Time(hours: 3), additionalServices: [removal])

        _ = Visit(client: gerasimova, date: Date(day: 7, month: 2, year: 2019), time: Time(hours: 15), service: brows, cost: 500, duration: Time(hours: 1))

        _ = Visit(client: gerasimova, date: Date(day: 6, month: 12, year: 2018), time: Time(hours: 12), service: manicure, cost: 1000, duration: Time(hours: 3), additionalServices: [removal])

        _ = Visit(client: gerasimova, date: Date(day: 29, month: 12, year: 2018), time: Time(hours: 15), service: manicure, cost: 1100, duration: Time(hours: 3), additionalServices: [removal])

        _ = Visit(client: gerasimova, date: Date(day: 16, month: 1, year: 2019), time: Time(hours: 12), service: manicure, cost: 1100, duration: Time(hours: 3), additionalServices: [removal])

        _ = Visit(client: gerasimova, date: Date(day: 12, month: 2, year: 2019), time: Time(hours: 16), service: brows, cost: 500, duration: Time(hours: 1))

        _ = Visit(client: gerasimova, date: Date(day: 8, month: 2, year: 2019), time: Time(hours: 12), service: manicure, cost: 1100, duration: Time(hours: 3), additionalServices: [removal])

        _ = Visit(client: gerasimova, date: Date(day: 28, month: 2, year: 2019), time: Time(hours: 12), service: manicure, cost: 1100, duration: Time(hours: 3), additionalServices: [removal], isCancelled: true)

        _ = Visit(client: gerasimova, date: Date(day: 12, month: 3, year: 2019), time: Time(hours: 12), service: manicure, cost: 1100, duration: Time(hours: 3), additionalServices: [removal])

        _ = Visit(client: gerasimova, date: Date(day: 15, month: 3, year: 2019), time: Time(hours: 12), service: brows, cost: 500, duration: Time(hours: 1))

        _ = Visit(client: gerasimova, date: Date(day: 29, month: 3, year: 2019), time: Time(hours: 12), service: manicure, cost: 1100, duration: Time(hours: 3), additionalServices: [removal])

        // Ольга Ольгина

        _ = Visit(client: olgina, date: Date(day: 8, month: 11, year: 2018), time: Time(hours: 9), service: manicure, cost: 1300, duration: Time(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: olgina, date: Date(day: 21, month: 11, year: 2018), time: Time(hours: 9), service: manicure, cost: 1300, duration: Time(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: olgina, date: Date(day: 7, month: 12, year: 2018), time: Time(hours: 9), service: manicure, cost: 1300, duration: Time(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: olgina, date: Date(day: 26, month: 12, year: 2018), time: Time(hours: 12), service: manicure, cost: 1300, duration: Time(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: olgina, date: Date(day: 17, month: 1, year: 2019), time: Time(hours: 9), service: manicure, cost: 1300, duration: Time(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: olgina, date: Date(day: 1, month: 2, year: 2019), time: Time(hours: 9), service: manicure, cost: 1300, duration: Time(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: olgina, date: Date(day: 14, month: 2, year: 2019), time: Time(hours: 12), service: manicure, cost: 1300, duration: Time(hours: 3), additionalServices: [strengthening, removal], isClientNotCome: true)

        _ = Visit(client: olgina, date: Date(day: 15, month: 3, year: 2019), time: Time(hours: 9), service: manicure, cost: 1300, duration: Time(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: olgina, date: Date(day: 28, month: 3, year: 2019), time: Time(hours: 12), service: manicure, cost: 1300, duration: Time(hours: 3), additionalServices: [strengthening, removal])

        // Елизавета Пешнова

        _ = Visit(client: peshnova, date: Date(day: 5, month: 2, year: 2019), time: Time(hours: 19), service: manicure, cost: 1800, duration: Time(hours: 4), additionalServices: [nailExtension, removal])

        _ = Visit(client: peshnova, date: Date(day: 9, month: 2, year: 2019), time: Time(hours: 12), service: brows, cost: 700, duration: Time(hours: 1))

        _ = Visit(client: peshnova, date: Date(day: 19, month: 2, year: 2019), time: Time(hours: 19), service: manicure, cost: 1800, duration: Time(hours: 4), additionalServices: [nailExtension, removal])

        _ = Visit(client: peshnova, date: Date(day: 28, month: 2, year: 2019), time: Time(hours: 12), service: brows, cost: 700, duration: Time(hours: 1))

        _ = Visit(client: peshnova, date: Date(day: 5, month: 3, year: 2019), time: Time(hours: 19), service: manicure, cost: 1800, duration: Time(hours: 4), additionalServices: [nailExtension, removal])

        _ = Visit(client: peshnova, date: Date(day: 6, month: 3, year: 2019), time: Time(hours: 12), service: brows, cost: 700, duration: Time(hours: 1))

        _ = Visit(client: peshnova, date: Date(day: 14, month: 3, year: 2019), time: Time(hours: 18), service: manicure, cost: 1800, duration: Time(hours: 4), additionalServices: [nailExtension, removal])

        _ = Visit(client: peshnova, date: Date(day: 29, month: 3, year: 2019), time: Time(hours: 15), service: manicure, cost: 1800, duration: Time(hours: 4), additionalServices: [nailExtension, removal])

        _ = Visit(client: peshnova, date: Date(day: 29, month: 3, year: 2019), time: Time(hours: 19), service: brows, cost: 700, duration: Time(hours: 1))

        // Виктория Троц

        _ = Visit(client: trots, date: Date(day: 7, month: 2, year: 2019), time: Time(hours: 9), service: manicure, cost: 1600, duration: Time(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: trots, date: Date(day: 26, month: 2, year: 2019), time: Time(hours: 9), service: manicure, cost: 1600, duration: Time(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: trots, date: Date(day: 14, month: 3, year: 2019), time: Time(hours: 9), service: manicure, cost: 1600, duration: Time(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: trots, date: Date(day: 26, month: 3, year: 2019), time: Time(hours: 19), service: manicure, cost: 1600, duration: Time(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: trots, date: Date(day: 7, month: 2, year: 2019), time: Time(hours: 19), service: manicure, cost: 1600, duration: Time(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: trots, date: Date(day: 28, month: 2, year: 2019), time: Time(hours: 9), service: manicure, cost: 1600, duration: Time(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: trots, date: Date(day: 6, month: 3, year: 2019), time: Time(hours: 9), service: manicure, cost: 1600, duration: Time(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: trots, date: Date(day: 22, month: 3, year: 2019), time: Time(hours: 12), service: manicure, cost: 1600, duration: Time(hours: 3), additionalServices: [strengthening, removal])

        // Екатерина Сергеева

        _ = Visit(client: sergeeva, date: Date(day: 5, month: 2, year: 2019), time: Time(hours: 9), service: manicure, cost: 1200, duration: Time(hours: 3), additionalServices: [withoutDesign, removal])

        _ = Visit(client: sergeeva, date: Date(day: 22, month: 2, year: 2019), time: Time(hours: 9), service: manicure, cost: 1200, duration: Time(hours: 3), additionalServices: [withoutDesign, removal])

        _ = Visit(client: sergeeva, date: Date(day: 7, month: 3, year: 2019), time: Time(hours: 9), service: manicure, cost: 1200, duration: Time(hours: 3), additionalServices: [withoutDesign, removal])

        _ = Visit(client: sergeeva, date: Date(day: 30, month: 3, year: 2019), time: Time(hours: 9), service: manicure, cost: 1200, duration: Time(hours: 3), additionalServices: [withoutDesign, removal])

        // Яна Осипова

        _ = Visit(client: osipova, date: Date(day: 22, month: 1, year: 2019), time: Time(hours: 9), service: manicure, cost: 1400, duration: Time(hours: 3), additionalServices: [removal])

        _ = Visit(client: osipova, date: Date(day: 13, month: 2, year: 2019), time: Time(hours: 9), service: manicure, cost: 1400, duration: Time(hours: 3), additionalServices: [removal])

        _ = Visit(client: osipova, date: Date(day: 13, month: 2, year: 2019), time: Time(hours: 12), service: brows, cost: 700, duration: Time(hours: 1))

        _ = Visit(client: osipova, date: Date(day: 1, month: 3, year: 2019), time: Time(hours: 9), service: manicure, cost: 1400, duration: Time(hours: 3), additionalServices: [removal])

        _ = Visit(client: osipova, date: Date(day: 1, month: 3, year: 2019), time: Time(hours: 12), service: brows, cost: 700, duration: Time(hours: 1))

        _ = Visit(client: osipova, date: Date(day: 13, month: 3, year: 2019), time: Time(hours: 9), service: manicure, cost: 1400, duration: Time(hours: 3), additionalServices: [removal])

        _ = Visit(client: osipova, date: Date(day: 13, month: 3, year: 2019), time: Time(hours: 12), service: brows, cost: 700, duration: Time(hours: 1))

        _ = Visit(client: osipova, date: Date(day: 26, month: 3, year: 2019), time: Time(hours: 9), service: manicure, cost: 1400, duration: Time(hours: 3), additionalServices: [removal])

        _ = Visit(client: osipova, date: Date(day: 29, month: 3, year: 2019), time: Time(hours: 20), service: brows, cost: 700, duration: Time(hours: 1))

        // Дарья Фёдорова

        _ = Visit(client: fedorova, date: Date(day: 30, month: 1, year: 2019), time: Time(hours: 9), service: manicure, cost: 1600, duration: Time(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: fedorova, date: Date(day: 13, month: 2, year: 2019), time: Time(hours: 13), service: manicure, cost: 1600, duration: Time(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: fedorova, date: Date(day: 21, month: 2, year: 2019), time: Time(hours: 9), service: manicure, cost: 1600, duration: Time(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: fedorova, date: Date(day: 6, month: 3, year: 2019), time: Time(hours: 13), service: manicure, cost: 1600, duration: Time(hours: 3), additionalServices: [strengthening, removal])

        _ = Visit(client: fedorova, date: Date(day: 27, month: 3, year: 2019), time: Time(hours: 12), service: manicure, cost: 1600, duration: Time(hours: 3), additionalServices: [strengthening, removal])
    }
}
