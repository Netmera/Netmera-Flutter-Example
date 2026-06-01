import 'package:netmera_flutter_sdk/NetmeraPushObject.dart';

Map<String, dynamic> mapPushObject(NetmeraPushObject push) => {
      'pushId': push.pushId,
      'pushInstanceId': push.pushInstanceId,
      'pushType': push.pushType,
      'inboxStatus': push.inboxStatus,
      'category': push.category,
      'categories': push.categories,
      'title': push.title,
      'subtitle': push.subtitle,
      'body': push.body,
      'mediaAttachmentURL': push.mediaAttachmentURL,
      'externalId': push.externalId,
      'sendDate': push.sendDate?.toString(),
      'expireTime': push.expireTime?.toString(),
      'deepLinkUrl': push.deepLinkUrl,
      'webPageUrl': push.webPageUrl,
      'pushAction': push.pushAction == null
          ? null
          : {
              'actionType': push.pushAction?.actionType?.toString(),
              'url': push.pushAction?.url,
            },
      'interactiveActions': push.interactiveActions
          .map((a) => {
                'id': a.getId(),
                'title': a.getActionTitle(),
                'actionType': a.getPushAction()?.actionType?.toString(),
              })
          .toList(),
      'carousel': push.carousel
          .map((c) => {
                'id': c.id,
                'picturePath': c.picturePath,
                'actionType': c.action?.actionType?.toString(),
              })
          .toList(),
      'customJson': push.customJson,
    };

String getPushObjectString(NetmeraPushObject push) => [
      'pushId=${push.pushId}',
      'pushInstanceId=${push.pushInstanceId}',
      'pushType=${push.pushType}',
      'inboxStatus=${push.inboxStatus}',
      'category=${push.category}',
      'categories=${push.categories}',
      'title=${push.title}',
      'subtitle=${push.subtitle}',
      'body=${push.body}',
      'mediaAttachmentURL=${push.mediaAttachmentURL}',
      'externalId=${push.externalId}',
      'sendDate=${push.sendDate}',
      'expireTime=${push.expireTime}',
      'deepLinkUrl=${push.deepLinkUrl}',
      'webPageUrl=${push.webPageUrl}',
      'pushAction=(type=${push.pushAction?.actionType}, url=${push.pushAction?.url})',
      'interactiveActions=${push.interactiveActions.map((a) => '(id=${a.getId()}, title=${a.getActionTitle()}, action=${a.getPushAction()?.actionType})')}',
      'carousel=${push.carousel.map((c) => '(id=${c.id}, picturePath=${c.picturePath}, action=${c.action?.actionType})')}',
      'customJson=${push.customJson}',
    ].join(', ');