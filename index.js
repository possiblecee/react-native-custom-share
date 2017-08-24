
import { NativeModules, Platform } from 'react-native';

class RNCustomShare {
  static shareOnInstagramWithCallback(base64Str){
    return new Promise((resolve, reject) => {
      if (Platform.OS === "ios") {
        NativeModules.RNCustomShare.shareOnInstagramWithCallback(base64Str,(e) => {
          return reject({ error: e });
        },(e) => {
          return resolve({
            message: e
          });
        });
      } else {
        NativeModules.RNCustomShare.shareWithInstagram(base64Str,(e) => {
          return reject({ error: e });
        },(e) => {
          resolve({
            message: e
          });
        });
      }
    });
  }

  static isInstalled(app) {
    if (Platform.OS === "ios") {
      return NativeModules.RNCustomShare[app] ? app : null;
    }
  }

  static share(p, message, url) {
    if (Platform.OS === "ios") {
      return new Promise((resolve, reject) => {
        if (p === 'twitter') {
          NativeModules.RNCustomShare.shareOnTwitterWithCallback(message, url,(e) => {
            return reject({ error: e });
          },(e) => {
            return resolve({
              message: e
            });
          });
        } else if (p === 'whatsapp') {
          NativeModules.RNCustomShare.shareOnWhatsappWithCallback(message, url,(e) => {
            return reject({ error: e });
          },(e) => {
            return resolve({
              message: e
            });
          });
        } else if (p === 'facebook') {
          NativeModules.RNCustomShare.shareOnFacebookWithCallback(message, url,(e) => {
            return reject({ error: e });
          },(e) => {
            return resolve({
              message: e
            });
          });
        }
      });

    }
  }
}

export default RNCustomShare;
