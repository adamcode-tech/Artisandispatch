import { View, StyleSheet } from 'react-native';
import MapView from 'react-native-maps';

const FindCoachScreen = () => {
  // Position initiale de la carte (Paris)
  const initialRegion = {
    latitude: 48.8566,
    longitude: 2.3522,
    latitudeDelta: 0.0922,
    longitudeDelta: 0.0421,
  };

  return (
    <View style={styles.container}>
      <MapView
        style={styles.map}
        initialRegion={initialRegion}
        showsUserLocation={true} // Affiche la position de l'utilisateur
        showsMyLocationButton={true} // Ajoute un bouton pour recentrer sur la position
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  map: {
    width: '100%',
    height: '100%',
  },
});

export default FindCoachScreen; 