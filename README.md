# PatternMystery

1~3인 온라인 협동 공포 미스터리 어드벤처의 Godot 4 프로토타입입니다.

현재 단계는 한 클라이언트에서 다음 기본 루프를 검증합니다.

> 장소 이동 → 오브젝트 조사 → 개인 저널 기록 → 다른 장소 이동 → 저널 원문 재열람

## 실행

Godot 4.7.2에서 `project.godot`을 열거나 다음 명령으로 실행합니다.

```powershell
& 'C:\Users\Admin\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --path 'C:\Users\Admin\Desktop\PatternMystery'
```

## 조작

- 왼쪽 `조사` 버튼으로 현재 장소의 오브젝트를 조사합니다.
- 왼쪽 `이동` 버튼으로 연결된 장소로 이동합니다.
- 오른쪽 개인 저널의 `자료`와 `목격` 항목을 클릭해 원문과 발견 메타데이터를 다시 봅니다.

## 현재 구현

- 중앙복도, 교무실, 방송실, 별관 대기실
- 장소별 Placeholder 색상과 설명
- 장소별 조사 오브젝트
- 문서 직접 조사
- 개인 저널 `material` / `witness`
- 발견 장소, 순서, 발견자 메타데이터
- 동일 항목 중복 등록 방지

## 아직 구현하지 않음

- 멀티플레이와 ENet
- Host/Client
- SLOT_8/SLOT_21
- CH1 Pattern State Machine과 본편 사건
- 저널 공유
- 저장/불러오기
- 최종 아트

## 구조

- `scripts/game_state.gd`: 현재 위치, 이동 검증, 조사, 개인 저널 상태
- `scripts/main.gd`: 장면형 UI 렌더링과 입력 연결
- `scenes/Main.tscn`: 단일 Placeholder 게임 화면
- `tests/basic_loop_test.gd`: 기본 이동·조사·저널 self-test

처음부터 범용 Rule Engine을 만들지 않습니다. CH1 Vertical Slice에서 필요한 Guard를 명시적으로 구현하고, 다음 Chapter에서도 반복되는 부분만 나중에 공통화합니다.

## 권한 방향

현재는 한 클라이언트지만 모든 상태 변경은 `PrototypeGameState`의 행동 메서드를 통합니다. 다음 단계에서 Host가 이 객체를 소유하고 클라이언트는 행동 의도만 보내도록 확장합니다. 전체 World State를 클라이언트에 복제하지 않고 각 플레이어에게 허용된 View만 전달합니다.

## 테스트

```powershell
& 'C:\Users\Admin\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'C:\Users\Admin\Desktop\PatternMystery' --script res://tests/basic_loop_test.gd
```
