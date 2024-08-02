---
to: src/socket/index.ts
force: true
---

import dlv from 'dlv';
import { TopicTypes } from './utils';
import { cookies } from 'src/utils/cookie';
import { isEmpty,isFunction } from 'src/utils/validation';


const myDomain = 'https://my.domain.com'

type topicValue = {
  handler: (data: any) => void;
  validator: (data: any) => boolean;
};

export type TopicListTypes = {
  name: TopicTypes;
  handler: (data: any) => void;
};

const DEFAULT_RETRY_IN_MILLIS = 1000;
const MAX_RETRY_IN_MILLIS = 5000;

class Socket {
  _ws = {} as WebSocket;
  _topicsList = {} as Record<string, Record<string, topicValue>>;
  timer = {} as any;
  pendingPing = 0;
  lastOnlineTime = Date.now();

  retryInMillis = DEFAULT_RETRY_IN_MILLIS;

  orgid: number;
  authToken: string;
  connected = false;

  constructor() {
    cookies.set('alive', true, { path: '/' });
    this.authToken = cookies.get('authtoken');
    this.orgid = cookies.get('serviceOrgId');
    // document.cookie = "alive=true; max-age=3600";
  }
  connect() {
    let url = myDomain;
    let ws = new WebSocket(url);
    this._ws = ws;
    ws.onopen = (e) => this._handleOpen(e);
    ws.onmessage = (e) => this._handleMessage(e);
    ws.onerror = (e) => {
      this.incrementRetryInMillis();
      setTimeout(() => {
        this._reconnect();
      }, this.retryInMillis);
    };
    // ws.onclose = (e) => {
    //   console.log('Event Close' + e);
    //   this.retryInMillis *= 2;
    //   setTimeout(this.reconnect, this.retryInMillis);
    // };
  }

  incrementRetryInMillis() {
    this.retryInMillis *= 2;
    if (this.retryInMillis > MAX_RETRY_IN_MILLIS) {
      this.retryInMillis = MAX_RETRY_IN_MILLIS;
    }
  }

  private _handleMessage(msgEvent: MessageEvent) {
    let { data } = msgEvent || {};
    let { _topicsList } = this || {};
    if (!isEmpty(data)) {
      data = JSON.parse(data);
      this.pong(data);
      // handle type based on data
      let type = dlv(data, 'type');
      let currentTopic = _topicsList[type];
      if (!isEmpty(currentTopic)) {
        Object.entries(currentTopic).forEach(([_, value]: any) => {
          let { handler, validator } = value || {};
          if (isFunction(handler) && validator(data)) {
            handler(data);
          }
        });
      }
    }
  }

  private _reconnect() {
    this._ws.close();
    clearInterval(this.timer);
    this.timer = null;
    this.pendingPing = 0;
    this.connect();
  }

  private _handleOpen(e: Event) {
    this.retryInMillis = DEFAULT_RETRY_IN_MILLIS;
    if (this.timer != null) {
      clearInterval(this.timer);
      this.timer = null;
    }
    const interval = setInterval(() => {
      this.ping();
    }, 2000);
    this.timer = interval;
  }
  pong(data: any) {
    if (data?.topic === '__ping__') {
      this.pendingPing = 0;
      this.longOfflineReloadApp();
      this.lastOnlineTime = Date.now();
      if (cookies.get('alive') === 'false') {
        cookies.set('alive', true, { path: '/' });
      }
    }
  }
  longOfflineReloadApp() {
    const nowTime = Date.now();
    let { lastOnlineTime } = this || {};
    if (nowTime - lastOnlineTime > 3600000) {
      window.location.reload();
    }
  }
  ping() {
    if (this.pendingPing >= 4) {
      if (cookies.get('alive') === 'true') {
        cookies.set('alive', false, { path: '/' });
      }
      this._reconnect();
    }
    this.pendingPing = this.pendingPing + 1;
    let { _ws } = this || {};

    if (_ws.readyState == _ws.OPEN) {
      _ws.send(JSON.stringify({ topic: '__ping__' }));
    }
  }

  private _subscribe(
    type: string,
    handler: (data: any) => void,
    validator: (data: any) => boolean,
    uniqueId: string
  ) {
    if (!isEmpty(uniqueId)) {
      let { _topicsList } = this || {};
      let existingTopicList = _topicsList[type];
      if (!isEmpty(existingTopicList)) {
        _topicsList[type] = {
          ...existingTopicList,
          [uniqueId]: { handler, validator },
        };
      } else {
        _topicsList[type] = {
          [uniqueId]: { handler, validator },
        };
      }
    }
  }
  subscribeList(
    topicList: Array<TopicListTypes>,
    validator: (data: any) => boolean,
    uniqueId: string
  ) {
    if (!isEmpty(uniqueId)) {
      topicList.forEach((topic: TopicListTypes) => {
        let { name, handler } = topic || {};
        this._subscribe(name, handler, validator, uniqueId);
      });
    }
  }

  customSubscribeList(
    topicList: Array<TopicListTypes>,
    validator: (data: any) => boolean,
    uniqueId: string
  ) {
    if (!isEmpty(uniqueId)) {
      topicList.forEach((topic: TopicListTypes) => {
        let { name, handler } = topic || {};
        this._subscribe(name, handler, validator, uniqueId);
      });
    }
  }
}

export default new Socket();
