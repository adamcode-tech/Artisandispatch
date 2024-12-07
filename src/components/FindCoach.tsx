import { GoogleMap, LoadScript } from '@react-google-maps/api';

export default function FindCoach() {
  const center = {
    lat: 48.866667, // Paris coordinates
    lng: 2.333333
  };

  return (
    <div className="h-[600px] w-full">
      <LoadScript googleMapsApiKey="VOTRE_CLE_API">
        <GoogleMap
          mapContainerStyle={{ width: '100%', height: '100%' }}
          center={center}
          zoom={12}
        >
          {/* Contenu de la carte */}
        </GoogleMap>
      </LoadScript>
    </div>
  );
} 