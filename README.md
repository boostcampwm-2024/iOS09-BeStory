# BeStory

![제목을-입력해주세요_-001 (1)](https://github.com/user-attachments/assets/5d018e58-b30e-47f4-bf61-f885a56c6689)

<br>

> BeStory에서는 친구들과 촬영한 각자의 동영상을 모아 하나의 이야기를 엮어갈 수 있습니다. <br>
> 각자의 시선으로 담아낸 소중한 영상을 모아 우리들만의 특별한 동영상을 만들 수 있어요. <br>
> 동영상을 올리고, 동시에 편집하고, 하나의 결과물을 만들어보세요!

<br>

## 팀 - 차은우원빈현빈장원영
### 팀원 소개
|[S042 엄지혜](https://github.com/LURKS02)|[S008 김건우](https://github.com/around-forest)|[S017 김윤회](https://github.com/051198Hz)|[S062 정석영](https://github.com/jungseokyoung-cloud)|
|:---:|:---:|:---:|:---:|
|<img src="https://github.com/user-attachments/assets/d76291dd-3cda-463d-b788-12ce7383b787" width=150>|<img src="https://github.com/user-attachments/assets/f4ccfd6b-311d-4feb-ac16-df1f4edf3e0a" width=150>|<img src="https://github.com/user-attachments/assets/b4a7a216-1078-4f93-a234-d76e654de0f1" width=150>|<img src="https://github.com/user-attachments/assets/eb7b20a2-3e40-445e-9ba6-73ac909eccad" width=150>|
|나는 장원영|<- 장원영|나는 장원영 아님|1번 장원영|
| iOS | iOS | iOS | iOS |
<br>

# 서비스 소개

### 유저 찾기 기능 
레이더가 그러진 그룹 맺기 화면에서 친구들과 그룹을 맺을 수 있어요! <br>
- 가까운 거리의 친구들이 레이더 위에 보여져요. 
- 아이콘 모양의 친구를 터치해서 그룹을 맺고, 함께 추억을 만들 준비를 해요!

<img src ="https://github.com/user-attachments/assets/e544118b-c23a-4b07-9a23-88ff59aa7bda" width="700">
<br>
<br>

### 그룹 내 친구의 연결 상태 확인 기능 
화면 상단에서 그룹을 맺은 친구들을 확인할 수 있어요! <br>
- 잘 연결돼있다면 초록불, 불안정할 때는 빨간불로 바뀌어요.
- 참여하고 있는 그룹에서 떠나고 싶을 때는, 나가기 버튼을 눌러 그룹을 떠날 수 있어요.

<img src ="https://github.com/user-attachments/assets/e544118b-c23a-4b07-9a23-88ff59aa7bda" width="700">
<br>
<br>

### 동영상 공유 기능 
추억이 될 각자의 동영상을 공유해요! <br>
- 각자의 앨범에서 동영상을 선택하면, 다 함께 볼 수 있는 목록에 추가돼요.
- 목록에 있는 동영상을 터치해서, 다른 친구가 공유한 동영상을 재생해볼 수 있어요.
- 공유한 여러 동영상들은 편집 후 하나의 동영상으로 추억으로 만들어져요!

<img src ="https://github.com/user-attachments/assets/4e4e58f8-e5cc-40bc-b06f-ff7ce44d2d0e" width="700">
<br>
<br>


### 동영상 동시 편집 기능
공유한 동영상은 하나의 타임라인을 구성해요! <br>
타임라인 안에 있는 동영상들을 친구들과 함께 편집해 추억을 만들 수 있어요 <br>
- 타임라인 안에 있는 동영상들의 순서를 바꿀 수 있어요 <br>
- 동영상마다 보여줄 구간을 조절해서 추억에 담고 싶은 부분을 지정할 수 있어요 <br>

<img src = "https://github.com/user-attachments/assets/c8febe27-39fc-4993-8ab5-6a6980c3ffc3" width="700">
<br>
<br>


# 핵심 기술 소개

### 아키텍처
<img src = "https://github.com/user-attachments/assets/a192c8fa-f1f1-45ad-bbe6-953d031dee8c" width="700">
<br>

- Clean Architecture기반으로 는 크게 3가지로(Feature, Domain, Data) 나누었습니다. 
- 각 Layer간의 참조가 일어나는 경우, Dynamic Library를 통해 소스코드가 여러번 복사되지 않도록 했습니다. 
- 구현부는 Compositional Root에서 조립하기에 Static Library로 구현했습니다.

<br>

### 기술 스택
- Combine
- MultipeerConnectivity
- Consensus Algorithm
- CRDT with LWW & Vector Clock
