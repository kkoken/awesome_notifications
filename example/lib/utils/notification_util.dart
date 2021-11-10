import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// TO AVOID CONFLICT WITH MATERIAL DATE UTILS CLASS
import 'package:awesome_notifications/awesome_notifications.dart' hide DateUtils;
import 'package:awesome_notifications/awesome_notifications.dart' as Utils show DateUtils;

import 'package:awesome_notifications_example/models/media_model.dart';
import 'package:awesome_notifications_example/utils/common_functions.dart';
import 'package:awesome_notifications_example/utils/media_player_central.dart';
import 'package:url_launcher/url_launcher.dart';

/* *********************************************
    LARGE TEXT FOR OUR NOTIFICATIONS TESTS
************************************************ */

String lorenIpsumText = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut '
    'labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip '
    'ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat '
    'nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit'
    'anim id est laborum';

Future<void> externalUrl(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

int createUniqueID(int maxValue) {
  Random random = new Random();
  return random.nextInt(maxValue);
}

/* *********************************************
    PERMISSIONS
************************************************ */

Future<bool> redirectToPermissionsPage() async {
  await AwesomeNotifications().showNotificationConfigPage();
  return await AwesomeNotifications().isNotificationAllowed();
}

Future<bool> requestPermissionToSendNotifications(BuildContext context) async {
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Color(0xfffbfbfb),
              title: Text('Get Notified!',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/animated-bell.gif',
                    height: 200,
                    fit: BoxFit.fitWidth,
                  ),
                  Text(
                    'Allow Awesome Notifications to send you beautiful notifications!',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Later',
                      style: TextStyle(color: Colors.grey, fontSize: 18),
                    )),
                TextButton(
                  onPressed: () async {
                    isAllowed = await AwesomeNotifications().requestPermissionToSendNotifications();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Allow',
                    style: TextStyle(color: Colors.deepPurple, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ));
  }
  return isAllowed;
}

/* *********************************************
    BASIC NOTIFICATIONS
************************************************ */

Future<void> showBasicNotification(int id) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
    id: id,
    channelKey: 'basic_channel',
    title: 'Simple Notification',
    body: 'Simple body',
  ));
}

Future<void> showEmojiNotification(int id) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
    id: id,
    channelKey: 'basic_channel',
    title: 'Emojis are awesome too! ' +
        Emojis.smile_face_with_tongue +
        Emojis.smile_rolling_on_the_floor_laughing +
        Emojis.smile_smiling_face_with_heart_eyes,
    body:
        'Simple body with a bunch of Emojis! ${Emojis.transport_police_car} ${Emojis.animals_dog} ${Emojis.flag_UnitedStates} ${Emojis.person_baby}',
    bigPicture: 'https://tecnoblog.net/wp-content/uploads/2019/09/emoji.jpg',
    notificationLayout: NotificationLayout.BigPicture,
  ));
}

Future<void> showNotificationWithPayloadContent(int id) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id,
          channelKey: 'basic_channel',
          title: 'Simple notification',
          body: 'Only a simple notification',
          payload: {'uuid': 'uuid-test'}));
}

Future<void> showNotificationWithoutTitle(int id) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id, channelKey: 'basic_channel', body: 'Only a simple notification', payload: {'uuid': 'uuid-test'}));
}

Future<void> showNotificationWithoutBody(int id) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id, channelKey: 'basic_channel', title: 'plain title', payload: {'uuid': 'uuid-test'}));
}

Future<void> sendBackgroundNotification(int id) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(id: id, channelKey: 'basic_channel', payload: {'secret-command': 'block_user'}));
}

/* *********************************************
    BADGE NOTIFICATIONS
************************************************ */

Future<void> showBadgeNotification(int id) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id,
          channelKey: 'badge_channel',
          title: 'Badge test notification',
          body: 'This notification does activate badge indicator'),
      schedule: NotificationInterval(interval: 5, timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier()));
}

Future<void> showWithoutBadgeNotification(int id) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id,
          channelKey: 'basic_channel',
          title: 'Badge test notification',
          body: 'This notification does not activate badge indicator'),
      schedule: NotificationInterval(interval: 5, timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier()));
}

// ON BADGE METHODS, NULL CHANNEL SETS THE GLOBAL COUNTER

Future<int> getBadgeIndicator() async {
  int amount = await AwesomeNotifications().getGlobalBadgeCounter();
  return amount;
}

Future<void> setBadgeIndicator(int amount) async {
  await AwesomeNotifications().setGlobalBadgeCounter(amount);
}

Future<int> incrementBadgeIndicator() async {
  return await AwesomeNotifications().incrementGlobalBadgeCounter();
}

Future<int> decrementBadgeIndicator() async {
  return await AwesomeNotifications().decrementGlobalBadgeCounter();
}

Future<void> resetBadgeIndicator() async {
  await AwesomeNotifications().resetGlobalBadge();
}

/* *********************************************
    ACTION BUTTONS NOTIFICATIONS
************************************************ */

Future<void> showNotificationWithActionButtons(int id) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id,
          channelKey: 'basic_channel',
          title: 'Anonymous says:',
          body: 'Hi there!',
          payload: {'uuid': 'user-profile-uuid'}),
      actionButtons: [
        NotificationActionButton(key: 'READ', label: 'Mark as read', autoDismissable: true),
        NotificationActionButton(key: 'PROFILE', label: 'Profile', autoDismissable: true, enabled: false)
      ]);
}

Future<void> showNotificationWithIconsAndActionButtons(int id) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id,
          channelKey: 'basic_channel',
          title: 'Anonymous says:',
          body: 'Hi there!',
          payload: {'uuid': 'user-profile-uuid'}),
      actionButtons: [
        NotificationActionButton(key: 'READ', label: 'Mark as read', autoDismissable: true),
        NotificationActionButton(key: 'PROFILE', label: 'Profile', autoDismissable: true, color: Colors.green),
        NotificationActionButton(key: 'DISMISS', label: 'Dismiss', autoDismissable: true, isDangerousOption: true)
      ]);
}

Future<void> showNotificationWithActionButtonsAndReply(int id) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id,
          channelKey: 'basic_channel',
          title: 'Anonymous says:',
          body: 'Hi there!',
          payload: {'uuid': 'user-profile-uuid'}),
      actionButtons: [
        NotificationActionButton(
          key: 'REPLY',
          label: 'Reply',
          autoDismissable: true,
          buttonType: ActionButtonType.InputField,
        ),
        NotificationActionButton(key: 'READ', label: 'Mark as read', autoDismissable: true),
        NotificationActionButton(key: 'ARCHIVE', label: 'Archive', autoDismissable: true)
      ]);
}

/* *********************************************
    LOCKED (ONGOING) NOTIFICATIONS
************************************************ */

Future<void> showLockedNotification(int id) async {
  AwesomeNotifications().setChannel(NotificationChannel(
      channelKey: 'locked_notification',
      channelName: 'Locked notification',
      channelDescription: 'Channel created on the fly with lock option',
      locked: true));

  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id,
          channelKey: 'locked_notification',
          title: 'Locked notification',
          body: 'This notification is locked and cannot be dismissed',
          payload: {'uuid': 'uuid-test'}));
}

Future<void> showUnlockedNotification(int id) async {
  AwesomeNotifications().setChannel(NotificationChannel(
      channelKey: 'locked_notification',
      channelName: 'Unlocked notification',
      channelDescription: 'Channel created on the fly with lock option',
      locked: true));

  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id,
          channelKey: 'locked_notification',
          title: 'Unlocked notification',
          body: 'This notification is not locked and can be dismissed',
          payload: {'uuid': 'uuid-test'},
          locked: false));
}

/* *********************************************
    NOTIFICATION CHANNELS MANIPULATION
************************************************ */

Future<void> showNotificationImportance(int id, NotificationImportance importance) async {
  String importanceKey = importance.toString().toLowerCase().split('.').last;
  String channelKey = 'importance_' + importanceKey + '_channel';
  String title = 'Importance levels (' + importanceKey + ')';
  String body = 'Test of importance levels to ' + importanceKey;

  await AwesomeNotifications().setChannel(NotificationChannel(
      channelKey: channelKey,
      channelName: title,
      channelDescription: body,
      importance: importance,
      defaultColor: Colors.red,
      ledColor: Colors.red,
      vibrationPattern: highVibrationPattern));

  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id, channelKey: channelKey, title: title, body: body, payload: {'uuid': 'uuid-test'}));
}

/* *********************************************
    NOTIFICATION CHANNELS MANIPULATION
************************************************ */

Future<void> createTestChannel(String channelName) async {
  await AwesomeNotifications().setChannel(NotificationChannel(
      channelKey: channelName.toLowerCase().replaceAll(' ', '_'),
      channelName: channelName,
      channelDescription: "Channel created to test the channels manipulation."));
}

Future<void> updateTestChannel(String channelName) async {
  await AwesomeNotifications().setChannel(NotificationChannel(
      channelKey: channelName.toLowerCase().replaceAll(' ', '_'),
      channelName: channelName + " (updated)",
      channelDescription: "This channel was successfuly updated."));
}

Future<void> removeTestChannel(String channelName) async {
  await AwesomeNotifications().removeChannel(channelName.toLowerCase().replaceAll(' ', '_'));
}

/* *********************************************
    DELAYED NOTIFICATIONS
************************************************ */

Future<void> delayNotification(int id) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id,
          channelKey: "scheduled",
          title: 'scheduled title',
          body: 'scheduled body',
          payload: {'uuid': 'uuid-test'}),
      schedule: NotificationInterval(interval: 5, timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier()));
}

/* *********************************************
    DELAYED NOTIFICATIONS
************************************************ */

Future<void> showLowVibrationNotification(int id) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id,
          channelKey: 'low_intensity',
          title: 'Low vibration title',
          body: 'This is a notification with low vibration pattern',
          payload: {'uuid': 'uuid-test'}));
}

Future<void> showMediumVibrationNotification(int id) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id,
          channelKey: 'medium_intensity',
          title: 'Medium vibration title',
          body: 'This is a notification with medium vibration pattern',
          payload: {'uuid': 'uuid-test'}));
}

Future<void> showHighVibrationNotification(int id) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id,
          channelKey: 'high_intensity',
          title: 'High vibration title',
          body: 'This is a notification with high vibration pattern',
          payload: {'uuid': 'uuid-test'}));
}

Future<void> showCustomVibrationNotification(int id) async {
  AwesomeNotifications().setChannel(NotificationChannel(
      channelKey: "custom_vibration",
      channelName: "Custom vibration",
      channelDescription: "Channel created on the fly with custom vibration",
      vibrationPattern: Int64List.fromList([0, 1000, 200, 200, 1000, 1500, 200, 200]),
      ledOnMs: 1000,
      ledOffMs: 500));

  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id,
          channelKey: 'custom_vibration',
          title: 'That\'s all for today, folks!',
          bigPicture:
              'https://i0.wp.com/www.jornadageek.com.br/wp-content/uploads/2018/06/Looney-tunes.png?resize=696%2C398&ssl=1',
          notificationLayout: NotificationLayout.BigPicture,
          payload: {'uuid': 'uuid-test'}));
}

/* *********************************************
    COLORFUL AND LED NOTIFICATIONS
************************************************ */

Future<void> redNotification(int id, bool delayLEDTests) async {
  AwesomeNotifications().setChannel(NotificationChannel(
      channelKey: "colorful_notification",
      channelName: "Colorful notifications",
      channelDescription: "A red colorful notification",
      vibrationPattern: lowVibrationPattern,
      defaultColor: Colors.red,
      ledColor: Colors.red,
      ledOnMs: 1000,
      ledOffMs: 500));

  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id,
          channelKey: "colorful_notification",
          title: "<font color='${Colors.red.value}'>Red Notification</font>",
          body: "<font color='${Colors.red.value}'>A colorful notification</font>",
          payload: {'uuid': 'uuid-red'}),
      actionButtons: [
        NotificationActionButton(
          key: 'REPLY',
          label: 'Reply',
          autoDismissable: true,
          buttonType: ActionButtonType.InputField,
        ),
        NotificationActionButton(key: 'ARCHIVE', label: 'Archive', autoDismissable: true)
      ],
      schedule: delayLEDTests
          ? NotificationInterval(interval: 5, timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier())
          : null);
}

Future<void> blueNotification(int id, bool delayLEDTests) async {
  AwesomeNotifications().setChannel(NotificationChannel(
      channelKey: "colorful_notification",
      channelName: "Colorful notifications",
      channelDescription: "A red colorful notification",
      vibrationPattern: lowVibrationPattern,
      defaultColor: Colors.blueAccent,
      ledColor: Colors.blueAccent,
      ledOnMs: 1000,
      ledOffMs: 500));

  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id,
          channelKey: "colorful_notification",
          title: '<font color="${Colors.blueAccent.value}">Blue Notification</font>',
          body: "<font color='${Colors.blueAccent.value}'>A colorful notification</font>",
          payload: {'uuid': 'uuid-blue'}),
      actionButtons: [
        NotificationActionButton(
          key: 'REPLY',
          label: 'Reply',
          autoDismissable: true,
          buttonType: ActionButtonType.InputField,
        ),
        NotificationActionButton(key: 'ARCHIVE', label: 'Archive', autoDismissable: true)
      ],
      schedule: delayLEDTests
          ? NotificationInterval(interval: 5, timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier())
          : null);
}

Future<void> yellowNotification(int id, bool delayLEDTests) async {
  AwesomeNotifications().setChannel(NotificationChannel(
      channelKey: "colorful_notification",
      channelName: "Colorful notifications",
      channelDescription: "A red colorful notification",
      vibrationPattern: lowVibrationPattern,
      defaultColor: CupertinoColors.activeOrange,
      ledColor: CupertinoColors.activeOrange,
      ledOnMs: 1000,
      ledOffMs: 500));

  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id,
          channelKey: "colorful_notification",
          title: 'Yellow Notification',
          body: 'A colorful notification',
          backgroundColor: CupertinoColors.activeOrange,
          payload: {'uuid': 'uuid-yellow'}),
      actionButtons: [
        NotificationActionButton(
          key: 'REPLY',
          label: 'Reply',
          autoDismissable: true,
          buttonType: ActionButtonType.InputField,
        ),
        NotificationActionButton(key: 'ARCHIVE', label: 'Archive', autoDismissable: true)
      ],
      schedule: delayLEDTests
          ? NotificationInterval(interval: 5, timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier())
          : null);
}

Future<void> purpleNotification(int id, bool delayLEDTests) async {
  AwesomeNotifications().setChannel(NotificationChannel(
      channelKey: "colorful_notification",
      channelName: "Colorful notifications",
      channelDescription: "A purple colorful notification",
      vibrationPattern: lowVibrationPattern,
      defaultColor: Colors.deepPurple,
      ledColor: Colors.deepPurple,
      ledOnMs: 1000,
      ledOffMs: 500));

  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id,
          channelKey: "colorful_notification",
          title: '<font color="${Colors.deepPurple.value}">Purple Notification</font>',
          body: "<font color='${Colors.deepPurple.value}'>A colorful notification</font>",
          payload: {'uuid': 'uuid-purple'}),
      actionButtons: [
        NotificationActionButton(
          key: 'REPLY',
          label: 'Reply',
          autoDismissable: true,
          buttonType: ActionButtonType.InputField,
        ),
        NotificationActionButton(key: 'ARCHIVE', label: 'Archive', autoDismissable: true)
      ],
      schedule: delayLEDTests
          ? NotificationInterval(interval: 5, timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier())
          : null);
}

Future<void> greenNotification(int id, bool delayLEDTests) async {
  AwesomeNotifications().setChannel(NotificationChannel(
      channelKey: "colorful_notification",
      channelName: "Colorful notifications",
      channelDescription: "A green colorful notification",
      vibrationPattern: lowVibrationPattern,
      defaultColor: Colors.lightGreen,
      ledColor: Colors.lightGreen,
      ledOnMs: 1000,
      ledOffMs: 500));

  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id,
          channelKey: "colorful_notification",
          title: '<font color="${Colors.lightGreen.value}">Green Notification</font>',
          body: "<font color='${Colors.lightGreen.value}'>A colorful notification</font>",
          payload: {'uuid': 'uuid-green'}),
      actionButtons: [
        NotificationActionButton(
          key: 'REPLY',
          label: 'Reply',
          autoDismissable: true,
          buttonType: ActionButtonType.InputField,
        ),
        NotificationActionButton(key: 'ARCHIVE', label: 'Archive', autoDismissable: true)
      ],
      schedule: delayLEDTests
          ? NotificationInterval(interval: 5, timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier())
          : null);
}

/* *********************************************
    CUSTOM SOUND NOTIFICATIONS
************************************************ */

Future<void> showCustomSoundNotification(int id) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id,
          channelKey: "custom_sound",
          title: 'It\'s time to morph!',
          body: 'It\'s time to go save the world!',
          notificationLayout: NotificationLayout.BigPicture,
          bigPicture: 'asset://assets/images/fireman-hero.jpg',
          color: Colors.yellow,
          payload: {'secret': 'the green ranger and the white ranger are the same person'}));
}

/* *********************************************
    WAKE UP LOCK SCREEN NOTIFICATIONS
************************************************ */

Future<void> showNotificationWithWakeUp(int id) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id,
          channelKey: 'basic_channel',
          title: 'Hey! Wake up!!',
          body: 'Its time to wake up!',
          wakeUpScreen: true,
          criticalAlert: true,
          notificationLayout: NotificationLayout.BigPicture,
          bigPicture: 'https://media.tenor.com/images/5591f440176598f96050b09c943052c0/tenor.png',
          color: Colors.blueGrey),
      schedule: NotificationInterval(interval: 5));
}

/* *********************************************
    SILENCED NOTIFICATIONS
************************************************ */

Future<void> showNotificationWithNoSound(int id) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id,
          channelKey: "silenced",
          title: 'Silence, please!',
          body: 'Shhhhhh!!!',
          notificationLayout: NotificationLayout.BigPicture,
          bigPicture:
              'https://image.freepik.com/fotos-gratis/medico-serio-mostrando-o-gesto-de-silencio_1262-17188.jpg',
          color: Colors.blueGrey,
          payload: {'advice': 'shhhhhhh'}));
}

/* *********************************************
    BIG PICTURE NOTIFICATIONS
************************************************ */

Future<void> showBigPictureNetworkNotification(int id) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: 11,
          channelKey: 'big_picture',
          title: 'Big picture (Network)',
          body: '$lorenIpsumText\n\n$lorenIpsumText\n\n$lorenIpsumText',
          bigPicture:
              'https://media.wired.com/photos/598e35994ab8482c0d6946e0/master/w_2560%2Cc_limit/phonepicutres-TA.jpg',
          notificationLayout: NotificationLayout.BigPicture));
}

Future<void> showBigPictureAssetNotification(int id) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id,
          channelKey: "big_picture",
          title: 'Big picture (Asset)',
          body: '$lorenIpsumText\n\n$lorenIpsumText\n\n$lorenIpsumText',
          bigPicture: 'asset://assets/images/balloons-in-sky.jpg',
          notificationLayout: NotificationLayout.BigPicture,
          payload: {'uuid': 'uuid-test'}));
}

/// Just to simulates a file already saved inside device storage
Future<void> showBigPictureFileNotification(int id) async {
  String newFilePath = await downloadAndSaveImageOnDisk(
      'https://images.freeimages.com/images/large-previews/be7/puppy-2-1456421.jpg', 'newTestImage.jpg');

  //String newFilePath = await saveImageOnDisk(AssetImage('assets/images/happy-dogs.jpg'),'newTestImage.jpg');
  newFilePath = newFilePath.replaceFirst('/', '');
  String finalFilePath = 'file://' + (newFilePath);

  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id,
          channelKey: "big_picture",
          title: 'Big picture (File)',
          body: '$lorenIpsumText\n\n$lorenIpsumText\n\n$lorenIpsumText',
          bigPicture: finalFilePath,
          notificationLayout: NotificationLayout.BigPicture,
          payload: {'uuid': 'uuid-test'}));
}

Future<void> showBigPictureResourceNotification(int id) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id,
          channelKey: "big_picture",
          title: 'Big picture (Resource)',
          body: '$lorenIpsumText\n\n$lorenIpsumText\n\n$lorenIpsumText',
          bigPicture: 'resource://drawable/res_mansion',
          notificationLayout: NotificationLayout.BigPicture,
          payload: {'uuid': 'uuid-test'}));
}

Future<void> showLargeIconNotification(int id) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id,
          channelKey: "big_picture",
          title: 'Big picture title',
          body: '$lorenIpsumText\n\n$lorenIpsumText\n\n$lorenIpsumText',
          largeIcon:
              'https://image.freepik.com/vetores-gratis/modelo-de-logotipo-de-restaurante-retro_23-2148451519.jpg',
          notificationLayout: NotificationLayout.BigPicture,
          payload: {'uuid': 'uuid-test'}));
}

Future<void> showBigPictureAndLargeIconNotification(int id) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id,
          channelKey: "big_picture",
          title: 'Big <b>BIG</b> picture title',
          summary: 'Summary <i>text</i>',
          body: '$lorenIpsumText<br><br>$lorenIpsumText<br><br>$lorenIpsumText',
          largeIcon:
              'https://image.freepik.com/vetores-gratis/modelo-de-logotipo-de-restaurante-retro_23-2148451519.jpg',
          bigPicture: 'https://media-cdn.tripadvisor.com/media/photo-s/15/dd/20/61/al-punto.jpg',
          notificationLayout: NotificationLayout.BigPicture,
          payload: {'uuid': 'uuid-test'}));
}

Future<void> showBigPictureNotificationActionButtons(int id) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id,
          channelKey: "big_picture",
          title: 'Big <b>BIG</b> picture title',
          summary: 'Summary <i>text</i>',
          body: '$lorenIpsumText<br><br>$lorenIpsumText<br><br>$lorenIpsumText',
          largeIcon:
              'https://image.freepik.com/vetores-gratis/modelo-de-logotipo-de-restaurante-retro_23-2148451519.jpg',
          bigPicture: 'https://media-cdn.tripadvisor.com/media/photo-s/15/dd/20/61/al-punto.jpg',
          notificationLayout: NotificationLayout.BigPicture,
          color: Colors.indigoAccent,
          payload: {'uuid': 'uuid-test'}),
      actionButtons: [
        NotificationActionButton(key: 'READ', label: 'Mark as read', autoDismissable: true),
        NotificationActionButton(key: 'REMEMBER', label: 'Remember-me later', autoDismissable: false)
      ]);
}

Future<void> showBigPictureNotificationActionButtonsAndReply(int id) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id,
          channelKey: "big_picture",
          title: 'Big <b>BIG</b> picture title',
          summary: 'Summary <i>text</i>',
          body: '$lorenIpsumText<br><br>$lorenIpsumText<br><br>$lorenIpsumText',
          largeIcon:
              'https://image.freepik.com/vetores-gratis/modelo-de-logotipo-de-restaurante-retro_23-2148451519.jpg',
          bigPicture: 'https://media-cdn.tripadvisor.com/media/photo-s/15/dd/20/61/al-punto.jpg',
          notificationLayout: NotificationLayout.BigPicture,
          color: Colors.indigoAccent,
          payload: {'uuid': 'uuid-test'}),
      actionButtons: [
        NotificationActionButton(
            key: 'REPLY', label: 'Reply', autoDismissable: true, buttonType: ActionButtonType.InputField),
        NotificationActionButton(key: 'REMEMBER', label: 'Remember-me later', autoDismissable: true)
      ]);
}

Future<void> showBigPictureNotificationHideExpandedLargeIcon(int id) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id,
          channelKey: "big_picture",
          title: 'Big <b>BIG</b> picture title',
          summary: 'Summary <i>text</i>',
          body: '$lorenIpsumText<br><br>$lorenIpsumText<br><br>$lorenIpsumText',
          hideLargeIconOnExpand: true,
          largeIcon: 'https://img.itdg.com.br/tdg/images/blog/uploads/2019/05/hamburguer.jpg',
          bigPicture: 'https://img.itdg.com.br/tdg/images/blog/uploads/2019/05/hamburguer.jpg',
          notificationLayout: NotificationLayout.BigPicture,
          color: Colors.indigoAccent,
          payload: {'uuid': 'uuid-test'}));
}

/* *********************************************
    BIG TEXT NOTIFICATIONS
************************************************ */

Future<void> showBigTextNotification(int id) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id,
          channelKey: "big_text",
          title: 'Big text title',
          body: '$lorenIpsumText\n\n$lorenIpsumText\n\n$lorenIpsumText',
          notificationLayout: NotificationLayout.BigText,
          payload: {'uuid': 'uuid-test'}));
}

Future<void> showBigTextNotificationWithDifferentSummary(int id) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id,
          channelKey: "big_text",
          title: 'Big text title',
          summary: 'Notification summary loren ipsum',
          body: '$lorenIpsumText\n\n$lorenIpsumText\n\n$lorenIpsumText',
          notificationLayout: NotificationLayout.BigText,
          payload: {'uuid': 'uuid-test'}));
}

Future<void> showBigTextHtmlNotification(int id) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id,
          channelKey: "big_text",
          title: 'Big <b>BIG</b> text title',
          summary: 'Summary <i>text</i>',
          body: '$lorenIpsumText<br><br>$lorenIpsumText<br><br>$lorenIpsumText',
          notificationLayout: NotificationLayout.BigText,
          payload: {'uuid': 'uuid-test'}));
}

Future<void> showBigTextNotificationWithActionAndReply(int id) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id,
          channelKey: "big_text",
          title: 'Big <b>BIG</b> text title',
          summary: 'Summary <i>text</i>',
          body: '$lorenIpsumText<br><br>$lorenIpsumText<br><br>$lorenIpsumText',
          color: Colors.indigoAccent,
          notificationLayout: NotificationLayout.BigText,
          payload: {'uuid': 'uuid-test'}),
      actionButtons: [
        NotificationActionButton(
            key: 'REPLY', label: 'Reply', autoDismissable: true, buttonType: ActionButtonType.InputField),
        NotificationActionButton(key: 'REMEMBER', label: 'Remember-me later', autoDismissable: true)
      ]);
}

/* *********************************************
    MEDIA CONTROLLER NOTIFICATIONS
************************************************ */

void updateNotificationMediaPlayer(int id, MediaModel? mediaNow) {
  if (mediaNow == null) {
    cancelNotification(id);
    return;
  }

  AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id,
          channelKey: 'media_player',
          title: mediaNow.bandName,
          body: mediaNow.trackName,
          summary: MediaPlayerCentral.isPlaying ? 'Now playing' : '',
          notificationLayout: NotificationLayout.MediaPlayer,
          largeIcon: mediaNow.diskImagePath,
          color: Colors.purple.shade700,
          autoDismissable: false,
          showWhen: false),
      actionButtons: [
        NotificationActionButton(
            key: 'MEDIA_PREV',
            icon: 'resource://drawable/res_ic_prev' + (MediaPlayerCentral.hasPreviousMedia ? '' : '_disabled'),
            label: 'Previous',
            autoDismissable: false,
            showInCompactView: false,
            enabled: MediaPlayerCentral.hasPreviousMedia,
            buttonType: ActionButtonType.KeepOnTop),
        MediaPlayerCentral.isPlaying
            ? NotificationActionButton(
                key: 'MEDIA_PAUSE',
                icon: 'resource://drawable/res_ic_pause',
                label: 'Pause',
                autoDismissable: false,
                showInCompactView: true,
                buttonType: ActionButtonType.KeepOnTop)
            : NotificationActionButton(
                key: 'MEDIA_PLAY',
                icon: 'resource://drawable/res_ic_play' + (MediaPlayerCentral.hasAnyMedia ? '' : '_disabled'),
                label: 'Play',
                autoDismissable: false,
                showInCompactView: true,
                enabled: MediaPlayerCentral.hasAnyMedia,
                buttonType: ActionButtonType.KeepOnTop),
        NotificationActionButton(
            key: 'MEDIA_NEXT',
            icon: 'resource://drawable/res_ic_next' + (MediaPlayerCentral.hasNextMedia ? '' : '_disabled'),
            label: 'Previous',
            showInCompactView: true,
            enabled: MediaPlayerCentral.hasNextMedia,
            buttonType: ActionButtonType.KeepOnTop),
        NotificationActionButton(
            key: 'MEDIA_CLOSE',
            icon: 'resource://drawable/res_ic_close',
            label: 'Close',
            autoDismissable: true,
            showInCompactView: true,
            buttonType: ActionButtonType.KeepOnTop)
      ]);
}

int _messageIncrement = 0;
Future<void> simulateChatConversation({required String groupKey}) async {
  _messageIncrement++ % 4 < 2
      ? createMessagingNotification(
          channelKey: 'chats',
          groupKey: groupKey,
          chatName: 'Jhonny\'s Group',
          username: 'Jhonny',
          largeIcon: 'asset://assets/images/80s-disc.jpg',
          message: 'Jhonny\'s message $_messageIncrement',
        )
      : createMessagingNotification(
          channelKey: 'chats',
          groupKey: 'jhonny_group',
          chatName: 'Michael\'s Group',
          username: 'Michael',
          largeIcon: 'asset://assets/images/dj-disc.jpg',
          message: 'Michael\'s message $_messageIncrement',
        );
}

Future<void> simulateSendResponseChatConversation({required String msg, required String groupKey}) async {
  createMessagingNotification(
    channelKey: 'chats',
    groupKey: groupKey,
    chatName: 'Jhonny\'s Group',
    username: 'you',
    largeIcon: 'asset://assets/images/rock-disc.jpg',
    message: msg,
  );
}

Future<void> createMessagingNotification(
    {required String channelKey,
    required String groupKey,
    required String chatName,
    required String username,
    required String message,
    String? largeIcon,
    bool checkPermission = true}) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: createUniqueID(AwesomeNotifications.maxID),
          groupKey: groupKey,
          channelKey: channelKey,
          summary: chatName,
          title: username,
          body: message,
          largeIcon: largeIcon,
          notificationLayout: NotificationLayout.Messaging),
      actionButtons: [
        NotificationActionButton(
          key: 'REPLY',
          label: 'Reply',
          buttonType: ActionButtonType.InputField,
          autoDismissable: false,
        ),
        NotificationActionButton(
          key: 'READ',
          label: 'Mark as Read',
          autoDismissable: true,
          buttonType: ActionButtonType.InputField,
        )
      ]);
}

/* *********************************************
    INBOX NOTIFICATIONS
************************************************ */

Future<void> showInboxNotification(int id) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: "inbox",
        title: '5 New mails from tester@gmail.com',
        body: '<b>You are our 10.000 visitor! Congratz!</b> You just won our prize'
            '\n'
            '<b>Want to loose weight?</b> Are you tired from false advertisements? '
            '\n'
            '<b>READ MY MESSAGE</b> Stop to ignore me!'
            '\n'
            '<b>READ MY MESSAGE</b> Stop to ignore me!'
            '\n'
            '<b>READ MY MESSAGE</b> Stop to ignore me!'
            '\n'
            '<b>READ MY MESSAGE</b> Stop to ignore me!'
            '\n'
            '<b>READ MY MESSAGE</b> Stop to ignore me!'
            '\n'
            '<b>READ MY MESSAGE</b> Stop to ignore me!'
            '\n'
            '<b>READ MY MESSAGE</b> Stop to ignore me!'
            '\n'
            '<b>READ MY MESSAGE</b> Stop to ignore me!'
            '\n'
            '<b>READ MY MESSAGE</b> Stop to ignore me!'
            '\n'
            '<b>READ MY MESSAGE</b> Stop to ignore me!'
            '\n'
            '<b>READ MY MESSAGE</b> Stop to ignore me!'
            '\n'
            '<b>READ MY MESSAGE</b> Stop to ignore me!',
        summary: 'E-mail inbox',
        largeIcon:
            'https://img.rawpixel.com/s3fs-private/rawpixel_images/website_content/366-mj-7703-fon-jj.jpg?w=800&dpr=1&fit=default&crop=default&q=65&vib=3&con=3&usm=15&bg=F4F4F3&ixlib=js-2.2.1&s=d144b28b5ebf828b7d2a1bb5b31efdb6',
        notificationLayout: NotificationLayout.Inbox,
        payload: {'uuid': 'uuid-test'},
      ),
      actionButtons: [
        NotificationActionButton(
            key: 'DISMISS',
            label: 'Dismiss',
            buttonType: ActionButtonType.DisabledAction,
            autoDismissable: true,
            icon: 'resource://drawable/res_ic_close'),
        NotificationActionButton(
          key: 'READ',
          label: 'Mark as read',
          autoDismissable: true,
          //icon: 'resources://drawable/res_ic_close'
        )
      ]);
}

/* *********************************************
    INBOX NOTIFICATIONS
************************************************ */

Future<void> showGroupedNotifications(id) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: 1, channelKey: 'grouped', title: 'Little Jhonny', body: 'Hey dude! Look what i found!'));

  sleep(Duration(seconds: 2));

  var maxStep = 10;
  for (var simulatedStep = 1; simulatedStep <= maxStep + 1; simulatedStep++) {
    await Future.delayed(Duration(seconds: 1), () async {
      if (simulatedStep > maxStep) {
        await AwesomeNotifications().createNotification(
            content: NotificationContent(
                id: id,
                channelKey: 'grouped',
                title: 'Download finished',
                body: 'filename.txt',
                payload: {'file': 'filename.txt', 'path': '-rmdir c://ruwindows/system32/huehuehue'},
                locked: false));
      } else {
        await AwesomeNotifications().createNotification(
            content: NotificationContent(
                id: id,
                channelKey: 'grouped',
                title: 'Downloading fake file in progress ($simulatedStep of $maxStep)',
                body: 'filename.txt',
                payload: {'file': 'filename.txt', 'path': '-rmdir c://ruwindows/system32/huehuehue'},
                notificationLayout: NotificationLayout.ProgressBar,
                progress: min((simulatedStep / maxStep * 100).round(), 100),
                locked: true));
      }
    });
  }

  await AwesomeNotifications()
      .createNotification(content: NotificationContent(id: 2, channelKey: 'grouped', title: 'Cyclano', body: 'What?'));

  sleep(Duration(seconds: 2));

  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: 3, channelKey: 'grouped', title: 'Little Jhonny', body: 'This push notifications plugin is amazing!'));

  sleep(Duration(seconds: 2));

  await AwesomeNotifications().createNotification(
      content: NotificationContent(id: 4, channelKey: 'grouped', title: 'Little Jhonny', body: 'Its perfect!'));

  sleep(Duration(seconds: 2));

  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: 5,
          channelKey: 'grouped',
          title: 'Little Jhonny',
          body: 'I gonna contribute with the project! For sure!'));
}

/* *********************************************
    LIST SCHEDULED NOTIFICATIONS
************************************************ */

Future<void> listScheduledNotifications(BuildContext context) async {
  List<NotificationModel> activeSchedules = await AwesomeNotifications().listScheduledNotifications();
  for (NotificationModel schedule in activeSchedules) {
    debugPrint('pending notification: ['
        'id: ${schedule.content!.id}, '
        'title: ${schedule.content!.titleWithoutHtml}, '
        'schedule: ${schedule.schedule.toString()}'
        ']');
  }
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Text('${activeSchedules.length} schedules founded'),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<String> getCurrentTimeZone() {
  return AwesomeNotifications().getLocalTimeZoneIdentifier();
}

Future<String> getUtcTimeZone() {
  return AwesomeNotifications().getUtcTimeZoneIdentifier();
}

Future<void> repeatMinuteNotification() async {
  String localTimeZone = await AwesomeNotifications().getLocalTimeZoneIdentifier();
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: -1,
          channelKey: 'scheduled',
          title: 'Notification at every single minute',
          body: 'This notification was schedule to repeat at every single minute.',
          notificationLayout: NotificationLayout.BigPicture,
          bigPicture: 'asset://assets/images/melted-clock.png'),
      schedule: NotificationInterval(interval: 60, timeZone: localTimeZone, repeats: true));
}

Future<void> repeatMultiple5Crontab() async {
  String localTimeZone = await AwesomeNotifications().getLocalTimeZoneIdentifier();
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: -1,
          channelKey: 'scheduled',
          title: 'Notification at every 5 seconds for 1 minute',
          body: 'This notification was schedule to repeat at every 5 seconds.'),
      schedule: NotificationAndroidCrontab(
          initialDateTime: DateTime.now().add(Duration(seconds: 10)).toUtc(),
          expirationDateTime: DateTime.now().add(Duration(seconds: 10, minutes: 1)).toUtc(),
          crontabExpression: '/5 * * * * ? *',
          timeZone: localTimeZone,
          repeats: true));
}

Future<void> repeatPreciseThreeTimes() async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: -1,
          channelKey: 'scheduled',
          title: 'Notification scheduled to play precisely 3 times',
          body: 'This notification was schedule to play precisely 3 times.',
          notificationLayout: NotificationLayout.BigPicture,
          bigPicture: 'asset://assets/images/melted-clock.png'),
      schedule: NotificationAndroidCrontab(preciseSchedules: [
        DateTime.now().add(Duration(seconds: 10)).toUtc(),
        DateTime.now().add(Duration(seconds: 25)).toUtc(),
        DateTime.now().add(Duration(seconds: 45)).toUtc()
      ], repeats: true));
}

Future<void> repeatMinuteNotificationOClock() async {
  String localTimeZone = await AwesomeNotifications().getLocalTimeZoneIdentifier();
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: -1,
          channelKey: 'scheduled',
          title: 'Notification at exactly every single minute',
          body: 'This notification was schedule to repeat at every single minute at clock.',
          notificationLayout: NotificationLayout.BigPicture,
          bigPicture: 'asset://assets/images/melted-clock.png'),
      schedule: NotificationCalendar(second: 0, millisecond: 0, timeZone: localTimeZone, repeats: true));
}

Future<void> showNotificationAtScheduleCron(DateTime scheduleTime) async {
  String timeZoneIdentifier = AwesomeNotifications.localTimeZoneIdentifier;
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: -1,
        channelKey: 'scheduled',
        title: 'Just in time!',
        body: 'This notification was schedule to shows at ' +
            (Utils.DateUtils.parseDateToString(scheduleTime.toLocal()) ?? '?') +
            ' $timeZoneIdentifier (' +
            (Utils.DateUtils.parseDateToString(scheduleTime.toUtc()) ?? '?') +
            ' utc)',
        notificationLayout: NotificationLayout.BigPicture,
        bigPicture: 'asset://assets/images/delivery.jpeg',
        payload: {'uuid': 'uuid-test'},
        autoDismissable: false,
      ),
      schedule: NotificationCalendar.fromDate(date: scheduleTime));
}

Future<void> showNotificationWithNoBadge(int id) async {
  AwesomeNotifications().setChannel(NotificationChannel(
      channelKey: 'no_badge',
      channelName: 'No Badge Notifications',
      channelDescription: 'Notifications with no badge',
      channelShowBadge: false));

  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id,
          channelKey: 'no_badge',
          title: 'no badge title',
          body: 'no badge body',
          payload: {'uuid': 'uuid-test'}));
}

Future<void> showProgressNotification(int id) async {
  var maxStep = 10;
  for (var simulatedStep = 1; simulatedStep <= maxStep + 1; simulatedStep++) {
    await Future.delayed(Duration(seconds: 1), () async {
      if (simulatedStep > maxStep) {
        await AwesomeNotifications().createNotification(
            content: NotificationContent(
                id: id,
                channelKey: 'progress_bar',
                title: 'Download finished',
                body: 'filename.txt',
                payload: {'file': 'filename.txt', 'path': '-rmdir c://ruwindows/system32/huehuehue'},
                locked: false));
      } else {
        await AwesomeNotifications().createNotification(
            content: NotificationContent(
                id: id,
                channelKey: 'progress_bar',
                title: 'Downloading fake file in progress ($simulatedStep of $maxStep)',
                body: 'filename.txt',
                payload: {'file': 'filename.txt', 'path': '-rmdir c://ruwindows/system32/huehuehue'},
                notificationLayout: NotificationLayout.ProgressBar,
                progress: min((simulatedStep / maxStep * 100).round(), 100),
                locked: true));
      }
    });
  }
}

Future<void> showIndeterminateProgressNotification(int id) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id,
          channelKey: 'progress_bar',
          title: 'Downloading fake file...',
          body: 'filename.txt',
          payload: {'file': 'filename.txt', 'path': '-rmdir c://ruwindows/system32/huehuehue'},
          notificationLayout: NotificationLayout.ProgressBar,
          progress: null,
          locked: true));
}

Future<void> showNotificationWithUpdatedChannelDescription(int id) async {
  AwesomeNotifications().setChannel(NotificationChannel(
      channelKey: 'updated_channel',
      channelName: 'Channel to update (updated)',
      channelDescription: 'Notifications with updated channel'));

  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: id,
          channelKey: 'updated_channel',
          title: 'updated notification channel',
          body: 'check settings to see updated channel description',
          payload: {'uuid': '0123456789'}));
}

Future<void> removeChannel() async {
  AwesomeNotifications().removeChannel('updated_channel');
}

Future<void> cancelSchedule(int id) async {
  await AwesomeNotifications().cancelSchedule(id);
}

Future<void> cancelAllSchedules() async {
  await AwesomeNotifications().cancelAllSchedules();
}

Future<void> dismissAllNotifications() async {
  await AwesomeNotifications().dismissAllNotifications();
}

Future<void> cancelNotification(int id) async {
  await AwesomeNotifications().cancel(id);
}

Future<void> dismissNotificationsByChannelKey(String channelKey) async {
  await AwesomeNotifications().dismissNotificationsByChannelKey(channelKey);
}

Future<void> dismissNotificationsByGroupKey(String groupKey) async {
  await AwesomeNotifications().dismissNotificationsByGroupKey(groupKey);
}

Future<void> cancelSchedulesByChannelKey(String channelKey) async {
  await AwesomeNotifications().cancelSchedulesByChannelKey(channelKey);
}

Future<void> cancelSchedulesByGroupKey(String groupKey) async {
  await AwesomeNotifications().cancelSchedulesByGroupKey(groupKey);
}

Future<void> cancelNotificationsByChannelKey(String channelKey) async {
  await AwesomeNotifications().cancelNotificationsByChannelKey(channelKey);
}

Future<void> cancelNotificationsByGroupKey(String groupKey) async {
  await AwesomeNotifications().cancelNotificationsByGroupKey(groupKey);
}

Future<void> dismissNotification(int id) async {
  await AwesomeNotifications().dismiss(id);
}

Future<void> cancelAllNotifications() async {
  await AwesomeNotifications().cancelAll();
}

String toTwoDigitString(int value) {
  return value.toString().padLeft(2, '0');
}
