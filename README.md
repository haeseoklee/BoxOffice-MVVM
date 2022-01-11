# BoxOffice MVVM

<div align="left">
  <img alt="swift" src="https://img.shields.io/badge/Swift-5.5%20-orange" />
  <img alt="swift" src="https://img.shields.io/badge/iOS-15.2-lightgrey" />
</div>

## 목차

* <a href="#프로젝트_개요">프로젝트 개요</a>
* <a href="#적용기술">적용기술</a>
* <a href="#아키텍처_구성도">아키텍처 구성도</a>
* <a href="#프로젝트_상세기능">프로젝트 상세기능</a>
* <a href="#디렉토리_구조">디렉토리 구조</a>



## 프로젝트_개요

네이버 커넥트 재단에서 운영하는 BoostCourse의 [iOS 앱 프로그래밍 심화과정](https://www.boostcourse.org/mo326) 마지막 프로젝트를 <a href="#아키텍처_구성도">MVVM 아키텍처</a>로 재구현하였습니다. 

BoxOffice 애플리케이션은 서버의 API를 통해 영화 정보를 요청하고, 가져온 정보를 테이블 뷰와 컬렉션 뷰를 활용하여 화면에 표현해줍니다. 

여러 조건 (예매율순, 큐레이션, 개봉일순)에 따라 영화 정보를 요청할 수 있고, 영화 목록 중 원하는 영화를 선택하여 상세 정보를 볼 수 있습니다. 

또한 리뷰 작성 버튼을 클릭하여 한 줄 감상평을 남길 수 있습니다.

## 적용기술

* [RxSwift](https://github.com/ReactiveX/RxSwift)
* [RxCocoa](https://github.com/ReactiveX/RxSwift)
* [RxViewController](https://github.com/devxoul/RxViewController)
* [RxGesture](https://github.com/RxSwiftCommunity/RxGesture)

## 아키텍처_구성도

![BoxOffice MVVM Architecture 001](https://user-images.githubusercontent.com/20268101/148633179-60beee09-cab5-4651-b0cd-b2ad22f10ac6.jpeg)

## 프로젝트_상세기능

### 1. 영화 목록

| ![120216339-dbd20800-c271-11eb-80ee-12759a44ca35](https://user-images.githubusercontent.com/20268101/148557072-4f995086-118f-4520-ae19-5bf8c4066bb2.png) | ![120216339-dbd20800-c271-11eb-80ee-12759a44ca35](https://user-images.githubusercontent.com/20268101/148557066-0b8225b2-87d7-4868-89ec-489cf12c179f.png) |
| ------------------------------------------------------------ | ------------------------------------------------------------ |

#### 화면 구성

* 탭 인터페이스를 통해 테이블 형태의 화면과 컬렉션 형태의 화면에 접근할 수 있습니다. 

* 테이블 화면의 셀에는 영화 포스터와 영화 정보(제복, 등급, 예매순위, 예매율, 개봉일)을 보여줍니다.

* 컬렉션 화면의 셀에는 영화 포스터와 등급을 함께 보여줍니다. 포스터 아래에는 영화정보 (제목, 평점, 순위, 예매율, 개봉일)를 보여줍니다.

#### 기능

* 화면 오른쪽 상단 바 버튼을 눌러 정렬 방식을 선택할 수 있습니다. (예매율/큐레이션/개봉일)
  * 테이블 화면에서 적용한 정렬방식은 컬렉션 화면에도 적용 됩니다. (두 개 뷰의 영화 정렬방식은 동일하게 적용됩니다)
* 테이블 뷰와 컬렉션 뷰를 아래쪽으로 잡아당기면 새로고침 됩니다.
* 테이블 뷰/컬렉션 뷰의 셀을 누르면 해당 영화의 상세 정보를 보여주는 2번 화면으로 전환합니다.

### 2. 영화 상세 정보

| ![120216339-dbd20800-c271-11eb-80ee-12759a44ca35](https://user-images.githubusercontent.com/20268101/148557058-97e59393-1f7d-4f8d-a47d-afbfa3cbeb29.png) | ![120216339-dbd20800-c271-11eb-80ee-12759a44ca35](https://user-images.githubusercontent.com/20268101/148557057-f8a50ca7-56f0-4bb3-9dfe-36b49efc11c7.png) |
| ------------------------------------------------------------ | ------------------------------------------------------------ |

#### 화면 구성

* 네비게이션 아이템의 타이틀은 이전 화면에서 선택한 영화 제목입니다.

* 영화 포스터, 소개, 줄거리, 감독/출연, 한줄평을 보여줍니다.

* 한줄평에서는 작성자의 프로필, 닉네임, 별점, 작성일, 그리고 코멘트를 보여줍니다.

* 한줄평 오른쪽 상단에는 새로운 한줄평을 남길 수 있는 버튼이 있습니다.

#### 기능

* 영화 포스터를 터치하면 포스터를 전체화면에서 볼 수 있습니다.
* 한줄평 오른쪽 상단의 새로운 한줄평 남기기 버튼을 터치하면 3번 화면으로 전환합니다.

### 3. 한줄평 작성

| ![120216339-dbd20800-c271-11eb-80ee-12759a44ca35](https://user-images.githubusercontent.com/20268101/148557053-99ee7777-fab5-4824-8579-1e81ed3e67f4.png) | ![120216339-dbd20800-c271-11eb-80ee-12759a44ca35](https://user-images.githubusercontent.com/20268101/148558801-c8a2ccc6-970e-46ac-aee4-45774d1041d5.png) |
| ------------------------------------------------------------ | ------------------------------------------------------------ |

#### 화면 구성

* 별점을 남길 수 있는 별점 선택 영역이 있습니다.
* 닉네임을 작성 할 수 있는 텍스트 필드가 있습니다.
* 한줄평을 작성할 수 있는 텍스트 뷰가 있습니다.
* 네비게이션 아이템으로 '완료'와 '취소' 버튼이 있습니다.

#### 기능

* 영화에 대한 한줄평을 남길 수 있습니다.
  * 5개의 별을 터치 또는 드래그하여 별점을 선택할 수 있습니다.
  * 선택된 별이 숫자로 환산되어 별 이미지 아래쪽에 보여집니다.
  * 별점은 0~10점 사이의 정수 단위 입니다.
* 작성자의 닉네임과 한줄평을 작성하고 '완료' 버튼을 누르면 새로운 한줄평을 등록하고 등록에 성공하면 이전화면으로 되돌아오고, 새로운 한줄평이 업데이트 됩니다.
* 닉네임 또는 한줄평이 모두 작성되지 않은 상태에서 '완료' 버튼을 누르면 경고 알림창이 뜹니다.
* '취소' 버튼을 누르면 이전 화면으로 되돌아 갑니다
* 기존에 작성했던 닉네임이 있다면 3번 화면으로 새로 진입할 때 기존의 닉네임이 입력되어 있습니다.



## 디렉토리_구조

```text
BoxOffice+MVVM
├── Soureces
│   ├── App
│   │   └── AppDelegate.swift
│   │   └── SceneDelegate.swift
│   ├── Models
│   ├── Domains
│   ├── Repositories
│   ├── ViewModels
│   ├── Views
│   ├── Utils
│   └── Constants
└── Resources
    ├── Assets
    ├── LaunchScreen.storyboard
    └── Info.plist

```