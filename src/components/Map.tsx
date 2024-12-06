import { GoogleMap, LoadScript } from '@react-google-maps/api';

const containerStyle = {
  width: '100%',
  height: '100%'
};

const center = {
  lat: 48.8566,
  lng: 2.3522
};

export function Map() {
  return (
    <LoadScript googleMapsApiKey="AIzaSyCOb94Dftq8IkFGeYZi2F0Aj2C5LcCxMCA">
      <GoogleMap
        mapContainerStyle={containerStyle}
        center={center}
        zoom={11}
      >
        {/* Marqueurs des coachs ici */}
      </GoogleMap>
    </LoadScript>
  );
}