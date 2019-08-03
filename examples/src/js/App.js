import React, {Component} from 'react';
import AMapLocation from 'react-native-amap-location-api';
import {StyleSheet, Text, View, TouchableOpacity, Platform} from "react-native";

AMapLocation.init({
    ios: "044a3fc11ceee93e3c539c303eff8394",
    android: "428caa9eaeb37090d2320b48d760c142"
});

AMapLocation.setOptions({
    once: true,
    needAddress: true,
    interval: 2000
});


export default class App extends Component {

    constructor(props) {
        super(props);
        this.state = {
            location: "暂无定位信息"
        }
    }

    componentDidMount() {
        this.geoListener = AMapLocation.addListener(location => {
                this.locationListener(location);
            }
        )
    }

    componentWillUnmount() {
        this.geoListener.remove();
        AMapLocation.destroyLocation();
    }

    start() {
        AMapLocation.startLocation({once: true, interval: 5000});
    }

    stop() {
        AMapLocation.stopLocation();
    }

    locationListener(location) {
        console.log("location: " + JSON.stringify(location));
        this.writeObj(location);
    }

    writeObj(obj) {
        let description = "";
        for (let i in obj) {
            let property = obj[i];
            description += i + " : " + property + "\n";
        }
        this.setState({
            location: description
        });
    }

    render() {
        return (
            <View style={styles.container}>
                <View style={{flexDirection: 'row', marginTop: 50}}>
                    <TouchableOpacity style={styles.btn}
                                      onPress={() => this.start()}
                                      activeOpacity={0.8}>
                        <Text style={styles.btnText}>开始定位</Text>
                    </TouchableOpacity>
                    <TouchableOpacity style={[styles.btn, {marginLeft: 100}]}
                                      onPress={() => this.stop()}
                                      activeOpacity={0.8}>
                        <Text style={styles.btnText}>停止定位</Text>
                    </TouchableOpacity>
                </View>
                <Text style={{flex: 1, marginTop: 30}}>{this.state.location}</Text>
            </View>
        );
    }
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        // justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: '#F5FCFF',
    },
    btn: {
        height: 44,
        paddingHorizontal: 20,
        backgroundColor: '#FF8A00',
        borderRadius: 2,
        ...Platform.select({
            ios: {
                overflow: 'hidden',//React-Native borderRadius 在IOS端失效的问题
            },
            android: {}
        }),
        justifyContent: 'center',
        alignItems: 'center'
    },
    btnText: {
        color: '#ffffff',
        fontSize: 16,
        textAlign: 'center'
    }
});
