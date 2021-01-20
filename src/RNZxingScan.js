// @flow
import React from 'react';
import PropTypes from 'prop-types';
import {
  ViewPropTypes,
  requireNativeComponent,
  View,
  ViewProps,
  NativeModules
} from 'react-native';



interface IDecodeResult {
    format: string;
    content: string;
}
interface IScannerProps extends ViewProps {
    onBarCodeRead: (result: IDecodeResult | null) => void;
}

const ZxingScanManager: Object = NativeModules.ZxingScanView
const ZxingScan =  requireNativeComponent('ZxingScanView');

export default class RNZxingScan extends React.Component<IScannerProps> {
  static propTypes = {
    ...ViewPropTypes,
    onBarCodeRead: PropTypes.func,
  }
  state = {
    isAuthorized: false,
  }
   async componentDidMount() {
    const hasCameraPermissions = await ZxingScanManager.checkVideoAuthorizationStatus();

    this.setState(
      {
        isAuthorized: hasCameraPermissions,
      })
    }



  render() {
           const { style,notAuthorizedView } = this.props;
            return ( <View style={{flex: 1}}>
              { this.state.isAuthorized && (<ZxingScan onBarCodeRead={this.handleResult}/>)}
                {this.props.children}
               </View> )
             
  }

   handleResult = ({ nativeEvent: result }: NativeSyntheticEvent<IDecodeResult>) => {
        this.props.onBarCodeRead(result);
    }


}
