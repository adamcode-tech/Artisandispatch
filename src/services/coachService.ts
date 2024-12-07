import axios from 'axios';
import { Coach } from '../types/coach';

const API_URL = 'votre_api_url';

export const getNearbyCoaches = async (latitude: number, longitude: number, radius: number = 5000): Promise<Coach[]> => {
  try {
    const response = await axios.get<Coach[]>(`${API_URL}/coaches/nearby`, {
      params: {
        latitude,
        longitude,
        radius,
      }
    });
    return response.data;
  } catch (error) {
    console.error('Erreur lors de la récupération des coachs:', error);
    return [];
  }
}; 