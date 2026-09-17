import XCTest

final class TreinoUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testNavigateAnyDayAndPersistWeight() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-treino-reset"]
        app.launch()
        XCTAssertTrue(app.navigationBars["Treino"].waitForExistence(timeout: 10))

        let todayJs = Calendar.current.component(.weekday, from: Date()) - 1
        let otherDayId = todayJs == 2 ? "week-Sex" : "week-Ter"
        let otherTitle = todayJs == 2 ? "Pernas" : "Pull"

        XCTAssertTrue(app.buttons["week-Qua"].waitForExistence(timeout: 8))
        app.buttons["week-Qua"].tap()
        XCTAssertTrue(app.staticTexts["Corrida fácil"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["open-program-pull"].waitForExistence(timeout: 5))

        if todayJs == 3 {
            XCTAssertTrue(app.staticTexts["Corrida fácil"].exists)
        } else {
            XCTAssertTrue(
                app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'pode treinar mesmo assim'")).firstMatch.waitForExistence(timeout: 5)
            )
        }

        app.buttons[otherDayId].tap()
        XCTAssertTrue(app.staticTexts[otherTitle].waitForExistence(timeout: 5))
        XCTAssertTrue(
            app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'pode treinar mesmo assim'")).firstMatch.waitForExistence(timeout: 5),
            "abrir outro dia da ficha não pode bloquear o treino"
        )

        app.buttons["week-Ter"].tap()
        XCTAssertTrue(app.staticTexts["Pull"].waitForExistence(timeout: 5))

        let kgField = app.textFields["kg-field-pull-warmup-0"]
        XCTAssertTrue(kgField.waitForExistence(timeout: 5))
        kgField.tap()
        kgField.typeText("10")
        tapOK(in: app)
        XCTAssertTrue(app.staticTexts["caption-pull-warmup"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["caption-pull-warmup"].label.contains("Registrado hoje"))

        try assertVariantHistoryIsIsolated(in: app)

        app.buttons["video-pull-warmup"].tap()
        XCTAssertTrue(app.buttons["Fechar"].waitForExistence(timeout: 8))
        app.buttons["Fechar"].tap()

        app.terminate()
        app.launchArguments = []
        app.launch()
        XCTAssertTrue(app.navigationBars["Treino"].waitForExistence(timeout: 10))
        app.buttons["week-Ter"].tap()
        XCTAssertTrue(app.staticTexts["caption-pull-warmup"].waitForExistence(timeout: 8))
        XCTAssertTrue(
            app.staticTexts["caption-pull-warmup"].label.contains("Registrado hoje"),
            "peso deveria sobreviver a fechar o app"
        )
    }

    private func assertVariantHistoryIsIsolated(in app: XCUIApplication) throws {
        let picker = app.descendants(matching: .any)["variant-pull-pulldown"]
        XCTAssertTrue(picker.waitForExistence(timeout: 5), "seletor de variação da puxada")
        picker.tap()
        let barra = app.descendants(matching: .any)["Barra fixa · corpo"]
        XCTAssertTrue(barra.waitForExistence(timeout: 5))
        barra.tap()

        let caption = app.staticTexts["caption-pull-pulldown"]
        XCTAssertTrue(caption.waitForExistence(timeout: 5))
        XCTAssertTrue(
            caption.label.contains("Primeira vez nesta variação"),
            "barra fixa não pode herdar o peso da puxada: \(caption.label)"
        )

        let kg = app.textFields["kg-field-pull-pulldown-0"]
        XCTAssertTrue(kg.waitForExistence(timeout: 5))
        kg.tap()
        kg.typeText("12")
        tapOK(in: app)
        XCTAssertTrue(caption.label.contains("Registrado hoje"))

        picker.tap()
        let puxada = app.descendants(matching: .any)["Puxada frente barra longa · máquina"]
        XCTAssertTrue(puxada.waitForExistence(timeout: 5))
        puxada.tap()
        XCTAssertTrue(caption.waitForExistence(timeout: 5))
        XCTAssertTrue(
            caption.label.contains("Primeira vez nesta variação"),
            "puxada não pode herdar o peso da barra fixa: \(caption.label)"
        )
    }

    private func tapOK(in app: XCUIApplication) {
        let ok = app.buttons["OK"]
        if ok.waitForExistence(timeout: 2) {
            ok.tap()
        }
    }
}
