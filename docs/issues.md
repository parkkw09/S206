# 이슈 & 개선점

현재 코드(HEAD `1d976fd`)에서 발견한 문제를 우선순위별로 정리합니다.
**목표 설계는 [`architecture.md`](./architecture.md) 에 기록되어 있으며**, 여기에는 현재 코드가 그 목표에 도달하지 못한 **갭** 과 추가로 발견한 품질 이슈가 모두 포함됩니다.

> 최신 갱신: 2026-06-26
> 항목 ID 는 안정적으로 유지되며, 해결된 항목은 본 문서에서 제거하고 [`issues-resolved.md`](./issues-resolved.md) 로 이관합니다.
> 과거 해결 기록은 항상 [`issues-resolved.md`](./issues-resolved.md) + [`CHANGELOG.md`](./CHANGELOG.md) 에서 확인할 수 있습니다.

## 🔴 Critical — 앱/테스트 정상 동작을 가로막음

> Critical 시리즈(C-1 ~ C-5)는 2026-04-22 라운드에 전부 해결되어 [`issues-resolved.md`](./issues-resolved.md#-critical) 로 이관되었습니다.
> 현재 열려 있는 Critical 이슈는 없습니다.

## 🟠 High — 설계 · 보안 · 빌드

> High 시리즈(H-1 ~ H-7)는 2026-04-22 라운드에 전부 해결되어 [`issues-resolved.md`](./issues-resolved.md#-high) 로 이관되었습니다.
> - 1차 라운드: H-1 ~ H-4 (Critical 해소와 함께 진행)
> - 2차 라운드: H-5 (API 키 분리), H-6 (ATS 축소), H-7 (배포 타겟 iOS 15.0 통일)
> 현재 열려 있는 High 이슈는 없습니다.

## 🟡 Medium — 품질 / 이름

> M-1 은 2026-06-26 라운드에 해결되어 [`issues-resolved.md`](./issues-resolved.md#m-1-regisrationdate-오타) 로 이관되었습니다.

### M-2. `SeoulData` (Local) 가 실질적으로 무용
- 빈 배열 반환만 수행하는 스텁. 용도(캐시 / 목업 / 오프라인) 를 결정해 구현하거나 삭제.
- 목표 설계에서도 Local 은 "필요해지면 추가" 로 열어둔 상태.

> M-3, M-4 는 2026-06-26 라운드에 해결되어 [`issues-resolved.md`](./issues-resolved.md#-medium) 로 이관되었습니다.

### M-5. `Localizable.strings` 가 현재 도메인과 완전히 무관
- **위치**: `S206/Resources/{en,ko}.lproj/Localizable.strings`
- **내용**: `app_name, new_book, detail_book, bookmark, ascending, descending, history, search, search_hint, add_bookmark, delete_bookmark` — 전부 **책/북마크** 앱용 잔재.
- **연결**: 코드/스토리보드에서 `NSLocalizedString` 참조 없음 → 죽은 리소스.
- **해결**: 문화행사 도메인 키로 전면 재작성 (`event_list_title`, `loading`, `error_network`, …).

### M-6. `Images.xcassets` 도 이전 프로젝트 잔재
- `book, bookmark, history, information, search` + `app_icon`.
- 현 화면에 사용되는 이미지 없음. 필요 에셋으로 재정의.

### M-7. `Colors.xcassets` 커스텀 팔레트 미사용
- Pantone 2021 세트(`illuminating, purple_200/500/700, teal_200/700, ultimate_gray`) 가 등록돼 있으나 Storyboard/코드 참조 없음.
- 사용 여부 결정 후 정리.

## 🟢 Low — 사소한 정리

### L-1. 주석 처리된 구버전 코드 블록 다수
- `AppDelegate`, `SceneDelegate`, `SeoulRepositoryImpl`, `MainViewController` 에 존재. 히스토리는 git 이 보관 → **코드에서는 제거** 권장 (필요 부분은 본 docs 로 이관).

### L-2. `UIRequiredDeviceCapabilities = armv7`
- iOS 11+ 이후 무의미 (64-bit 전용). 제거.

### L-3. `.DS_Store` 가 트래킹됨
- `.gitignore` 에 포함돼 있으나 이미 커밋된 `.DS_Store` 가 최소 3개 (`/`, `S206/`, `S206/App/`, `S206/Resources/`).
- `git rm --cached` 로 정리.

### L-4. `Response<T>` 이름이 너무 일반적
- 도메인에 다른 응답 타입이 늘어나면 충돌 위험. `EventListResponse` 등 구체화 검토.

### L-5. `SeoulData.swift` 파일 헤더 주석 불일치
- 헤더는 `S206Local.swift` / 실제 파일명은 `SeoulData.swift`. 통일.

### L-6. `SceneDelegate.appDelegate` 프로퍼티 미사용
- `let appDelegate = UIApplication.shared.delegate as! AppDelegate` 선언만 있고 현재 사용처 없음. Composition Root 가 들어오면서 정리될 예정.

### L-7. `Info.plist` 의 `LSApplicationCategoryType = ""` (빈 값) — ✅ RESOLVED (2026-04-22)
- H-5 의 Info.plist 정리 과정에서 빈 값 키를 제거했습니다. 상세는 [`issues-resolved.md`](./issues-resolved.md) 참조 (본 문서 다음 정리 라운드에 L-7 전용 블록으로 이관 예정).

### L-8. 파일 헤더 저자 주석 포맷
- 모든 파일 상단에 `Created by 박관웅 [parkkw09] on ...` 헤더가 있음. 프로젝트 스타일로 유지할지 결정 (템플릿/스크립트로 재생성할 때 일관성 확인).

---

## 카테고리별 요약

현재 **미해결** 이슈만 보여 줍니다. 해결된 ID 는 [`issues-resolved.md`](./issues-resolved.md) 참조.

| 카테고리 | Critical | High | Medium | Low |
| --- | --- | --- | --- | --- |
| 앱 동작 | — *(C-1, C-2, C-5 해결 — history 참조)* | — | — | — |
| 테스트 | — *(C-3, C-4 해결 — history 참조)* | — | — | — |
| 레이어/설계 | — | — *(H-1 ~ H-4 해결 — history 참조)* | M-2 | L-4 |
| 보안/설정 | — | — *(H-5, H-6 해결 — history 참조)* | — | L-2, ✅L-7 |
| 빌드 설정 | — | — *(H-7 해결 — history 참조)* | — | — |
| 네이밍/오타 | — | — *(H-2 에 통합, 해결됨)* | — *(M-1 해결 — history 참조)* | L-5 |
| 리소스 | — | — | M-5, M-6, M-7 | — |
| 리포 위생 | — | — | — | L-1, L-3, L-6, L-8 |

**상태 스냅샷 (2026-06-26)**: Critical 0건 / High 0건 / Medium M-1·M-3·M-4 해결 → 미해결 Medium M-2·M-5·M-6·M-7. 우선 진행은 **Medium (M-5 ~ M-7 리소스 정리, M-2 로컬 캐시)** 순.
