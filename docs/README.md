# S206 (Seoul Festival) 프로젝트 문서

> 이 폴더는 S206 프로젝트의 구조, 현재 상태, 이슈, 향후 작업을 기록하기 위한 공간입니다.
> 현재 설계는 **[architecture.md](./architecture.md)** 에 기술하고, 남은 작업·이슈는 `issues.md` / `TODO.md` 에서 추적합니다.
> (코드 자체가 현재 상태의 ground truth 이므로, 별도의 코드 스냅샷 문서는 두지 않습니다.)

## 개요

- 프로젝트명: **S206**
- 플랫폼: iOS (UIKit + Storyboard, `@main AppDelegate`)
- 언어: Swift 5.0 (async/await 사용)
- 배포 타겟: **iOS 15.0** (프로젝트/App/Tests 전부 통일, 2026-04-22)
- 목적: 서울 열린데이터광장 **문화행사 정보 API** (`culturalEventInfo`) 를 호출해 리스트로 보여주는 앱
- 외부 의존성 (SPM):
  - [Alamofire](https://github.com/Alamofire/Alamofire) — HTTP 통신
  - [Swinject](https://github.com/Swinject/Swinject) — DI 컨테이너

## 문서 인덱스

| 문서 | 성격 | 내용 |
| --- | --- | --- |
| [architecture.md](./architecture.md) | **설계** | Clean Architecture + MVVM 구조·DI·에러 흐름, mos↔S206 대응표 |
| [issues.md](./issues.md) | **갭 분석** | 현재 코드의 **미해결** 버그·개선점 (우선순위별) |
| [issues-resolved.md](./issues-resolved.md) | **히스토리** | 해결된 이슈의 "원래 현상 + 해결" 보존 기록 |
| [TODO.md](./TODO.md) | 작업 계획 | 이슈를 Phase 별 작업으로 묶은 체크리스트 |
| [CHANGELOG.md](./CHANGELOG.md) | 기록 | 이 docs 폴더 자체의 변경 이력 |

## 현재 vs 목표 — 한눈에 보기

2026-06-26 기준, Critical(C-1~C-5) + High(H-1~H-7) + Medium(M-1·M-3·M-4) 전부 해결되어 아래 항목은 모두 목표 상태입니다.
상세 이력은 [`issues-resolved.md`](./issues-resolved.md) 참조.

| 항목 | 현재 코드 | 목표 | 상태 |
| --- | --- | --- | --- |
| Composition Root | `DI/AppContainer` (Swinject) | `DI/AppContainer` | 🟢 일치 |
| MVVM | `MainViewModel` (Combine `@Published`) | MVVM | 🟢 일치 |
| UI 상태 | `LoadState` enum (idle/loading/loadingMore/success/error) | LoadState | 🟢 일치 |
| 페이지네이션 | PAGE_SIZE=50, `loadNextPage()`, 무한스크롤 | 페이지네이션 | 🟢 일치 |
| 도메인 모델 필드 수 | `CulturalEvent` 24필드 | mos 대응 24필드 | 🟢 일치 |
| 페이지 타입 | `CulturalEventPage(events:totalCount:)` | mos 대응 | 🟢 일치 |
| UseCase 호출 방식 | `callAsFunction(startIndex:endIndex:)` | mos `operator fun invoke` 대응 | 🟢 일치 |
| `SeoulRepository` 위치 | Domain | Domain | 🟢 일치 |
| `SeoulError` 위치 | `Domain/Errors/SeoulError.swift` | 동일 | 🟢 일치 |
| DTO→Domain 변환 | `SeoulMapper` (성공코드 검증 포함) | 동일 | 🟢 일치 |
| 네트워크 설정 | `NetworkConfig` 주입 | 동일 | 🟢 일치 |
| API 키 관리 | `Config/Secrets.xcconfig` + `Info.plist $(SEOUL_KEY)` | xcconfig 분리 | 🟢 일치 |
| ATS | `NSExceptionDomains.openapi.seoul.go.kr` | 동일 | 🟢 일치 |
| 배포 타겟 | iOS 15.0 (Project/App/Tests 통일) | 단일 값 | 🟢 일치 |
| 테스트 빌드 | ✅ `build-for-testing` 통과 | ✅ | 🟢 일치 |
| `Localizable.strings` | 이전 프로젝트 잔재 (책/북마크 키) | 문화행사 키 | 🔴 미완 |
| `Images.xcassets` | 이전 프로젝트 잔재 | 실제 에셋 | 🔴 미완 |
| `Colors.xcassets` | 미사용 팔레트 | 사용 여부 결정 필요 | 🟡 보류 |
| 로컬 캐시 | 없음 | CoreData/SwiftData (mos Room 대응) | 🟡 보류 |

## 실행 방법

### 1. API 키 준비 (최초 1회)

`S206` 앱은 서울 열린데이터광장 OpenAPI 키를 필요로 합니다. 이 키는 저장소에 **커밋되지 않으며**, 각 개발자가 로컬에 별도 파일로 보관합니다.

1. [서울 열린데이터광장](https://data.seoul.go.kr/) 에서 **문화행사 정보** API 인증키를 발급받습니다.
2. 템플릿 파일을 복사해 로컬 전용 시크릿 파일을 만듭니다.
   ```bash
   cp Config/Secrets.xcconfig.example Config/Secrets.xcconfig
   ```
3. `Config/Secrets.xcconfig` 의 `SEOUL_KEY` 값을 발급받은 키로 교체합니다.
   ```
   SEOUL_KEY = <YOUR_ACTUAL_KEY>
   ```
4. `Config/Secrets.xcconfig` 는 `.gitignore` 에 포함되어 있어 커밋되지 않습니다.
5. 빌드 시 Xcode 가 `SEOUL_KEY` build setting 을 `Info.plist` 의 `$(SEOUL_KEY)` 토큰에 주입하며, `NetworkConfig.fromBundle()` 이 이를 읽어 `SeoulApi` 에 전달합니다. 키가 비어 있으면 `SeoulError.missingConfiguration(key: "SEOUL_KEY")` 가 던져지고 `AppContainer` 가 `fatalError` 로 변환합니다.

> **키 교체**: `Config/Secrets.xcconfig` 의 값만 갱신하면 됩니다. 별도 빌드 설정 변경은 필요 없습니다.
>
> **git 히스토리 정리 (권장)**: 이 저장소 초기 히스토리에는 과거 `Info.plist` 에 평문으로 남아 있던 키가 아직 존재합니다. 운영 단계에서는 `git filter-repo` 로 히스토리에서 제거 + 키를 새로 재발급하는 것이 안전합니다.

### 2. 빌드 & 실행

1. `S206.xcodeproj` 를 Xcode 로 열기
2. SPM 패키지(Alamofire, Swinject) 자동 resolve 대기
3. 시뮬레이터/디바이스 선택 후 Run → Storyboard 가 `MainViewController` 를 생성하고 `SceneDelegate` 가 `AppContainer.inject(into:)` 를 통해 `SeoulUsecase` 를 주입합니다.
4. `viewDidAppear` 에서 실 API 를 호출해 `문화 행사 N건` 라벨 + 테이블 리스트를 표시합니다. 에러 시 `myLabel` 에 에러 메시지가 표시됩니다.

### 3. 테스트

```bash
xcodebuild -project S206.xcodeproj -scheme S206 \
  -destination 'generic/platform=iOS Simulator' build-for-testing
```

Mock 기반이므로 네트워크 없이도 실행됩니다.

## 진행 순서 권장

1. ~~Phase 1 — Composition Root 구축~~ ✅ 완료
2. ~~Phase 2 — 레이어 재배치~~ ✅ 완료
3. ~~Phase 3 — 테스트 복구~~ ✅ 완료 (CI 자동화만 잔여)
4. ~~Phase 4 — 보안/설정 정리 (H-5, H-6, H-7)~~ ✅ 완료 (README 키 가이드 + git 히스토리 정리만 잔여)
5. ~~Phase 5-A — mos 기조 정렬~~ ✅ 완료 (MVVM + LoadState + 24필드 + 페이지네이션 + callAsFunction)
6. **Phase 5-B — 리소스 정리 & 기능 확장** (`Localizable.strings`/`Images.xcassets` 재작성, 상세 화면, 로컬 캐시 등) ← **다음 진행**
