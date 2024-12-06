import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { MapPin, Home, User } from 'lucide-react';
import HomeScreen from '../screens/HomeScreen'; // Changed path
import ProfileScreen from '../screens/ProfileScreen'; // Changed path
import FindCoach from '../components/FindCoach';

const Tab = createBottomTabNavigator();

const MainNavigation = () => {
  return (
    <Tab.Navigator>
      <Tab.Screen 
        name="Accueil" 
        component={HomeScreen}
        options={{
          tabBarIcon: ({ color }) => <Home color={color} />
        }}
      />
      <Tab.Screen 
        name="Trouver un coach" 
        component={FindCoach}
        options={{
          tabBarIcon: ({ color }) => <MapPin color={color} />
        }}
      />
      <Tab.Screen 
        name="Profil" 
        component={ProfileScreen}
        options={{
          tabBarIcon: ({ color }) => <User color={color} />
        }}
      />
    </Tab.Navigator>
  );
};

export default MainNavigation; 