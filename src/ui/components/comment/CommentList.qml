﻿import QtQuick 2.12
import QtQuick.Controls 2.12
import "qrc:///ui/global/"
import "qrc:///ui/global/styles/"
import "qrc:///ui/components/"

Item {
    id: root
    implicitHeight: rootCol.implicitHeight
    property var pcursor: "no_more"
    property var contentId

    function open(js){
        modelCmt.clear();
        contentId = js.contentId
        AcService.getComment(js.contentId, 0, showComment)
    }

    function showComment(res){
        //console.log("showComment"+JSON.stringify(res))
        if(0 !== res.result){
            PopMsg.showError(res, mainwindowRoot)
            return
        }
        pcursor = res.pcursor
        commentCnt.text = res.commentCount
        for(var idx in res.hotComments){
            addCmt(res.hotComments[idx], res)
        }
        for(var idxR in res.rootComments){
            addCmt(res.rootComments[idxR], res)
        }
    }
    function addCmt(cmt, res){
        cmt.headImgUrl = cmt.headUrl[0].url
        var curCID = cmt.commentId
        if(undefined !== res.subCommentsMap[String(curCID)]){
            cmt.subCommentsJson = JSON.stringify(res.subCommentsMap[String(curCID)])
        }else{
            cmt.subCommentsJson = ""
        }
        modelCmt.append(cmt)
    }

    Column {
        id: rootCol
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 10
        topPadding: 10
        bottomPadding: 10

        Row {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 10
            Text {
                text: qsTr("Comment")
            }
            Text {
                id: commentCnt
            }
        }
        Row {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 10
            AvatarWithCover {
                id: avatarSelf
                width: 90
                height: width
                avatarUrl: Global.userInfo.avatar
            }
            Rectangle {
                id: cmtEditer
                height: editor.height
                width: parent.width-avatarSelf.width-parent.spacing
                color: "transparent"
                CommentEditor {
                    id: editor
                    anchors.left: parent.left
                    anchors.right: parent.right
                    acId: contentId
                }
            }
        }

        ListModel {
            id: modelCmt
        }
        Repeater {
            id: repCmt
            model: modelCmt
            delegate: CommentItem {
                js: model
                onReplyTo: {
                    editor.replyToId = cmtId
                }
            }
        }

        Button {
            width: parent.width
            text: qsTr("show more")
            font.pixelSize: AppStyle.font_large
            font.family: AppStyle.fontNameMain
            font.weight: Font.Normal
            visible: "no_more" !== pcursor
            onClicked: {
                AcService.getComment(contentId, pcursor, showComment)
            }
        }

        Component.onCompleted: {
            console.log("CommentList completed")
        }
    }
}
